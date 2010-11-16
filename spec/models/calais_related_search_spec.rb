require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe CalaisRelatedSearch do
  fixtures :affiliates, :calais_related_searches

  before(:each) do
    @affiliate = affiliates(:power_affiliate)
    @valid_attributes = {
      :affiliate => @affiliate,
      :term => "debt relief",
      :related_terms => "Personal finance | United States bankruptcy law | Mortgage Forgiveness Debt Relief Act",
      :locale => 'en'
    }
  end

  context "when creating a new instance" do
    it "should create a new instance given valid attributes" do
      CalaisRelatedSearch.create!(@valid_attributes)
    end

    should_validate_presence_of :term, :related_terms, :locale
    should_validate_uniqueness_of :term, :scope => [:affiliate_id, :locale]
    should_validate_inclusion_of :locale, :in => SUPPORTED_LOCALES
    should_belong_to :affiliate
  end

  describe "#populate_with_new_popular_terms" do
    before do
      @second_affiliate = affiliates(:basic_affiliate)
    end

    context "when some affiliates got searches yesterday" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => @affiliate.name, :query => "SOME new popular term")
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => @second_affiliate.name, :query => "SOME new popular term")
      end

      it "should call populate_affiliate_with_new_popular_terms for each one" do
        CalaisRelatedSearch.should_receive(:populate_affiliate_with_new_popular_terms).with(@affiliate.name)
        CalaisRelatedSearch.should_receive(:populate_affiliate_with_new_popular_terms).with(@second_affiliate.name)
        CalaisRelatedSearch.populate_with_new_popular_terms
      end
    end

    context "when there are more terms to process than are allowed by daily API quota" do
      before do
        ResqueSpec.reset!
        CalaisRelatedSearch.stub!(:daily_api_quota).and_return(2)
        DailyQueryStat.create!(:affiliate => @second_affiliate.name, :day => Date.yesterday, :times => 1000, :query => "first one")
        DailyQueryStat.create!(:affiliate => @affiliate.name, :day => Date.yesterday, :times => 1000, :query => "second one")
        DailyQueryStat.create!(:affiliate => @affiliate.name, :day => Date.yesterday, :times => 1000, :query => "third one")
      end

      it "should only enqueue up to the limit" do
        CalaisRelatedSearch.populate_with_new_popular_terms
        CalaisRelatedSearch.should have_queued(@second_affiliate.name, "first one")
        CalaisRelatedSearch.should have_queued(@affiliate.name, "second one")
        CalaisRelatedSearch.should_not have_queued(@affiliate.name, "third one")
      end
    end
  end

  describe "#populate_affiliate_with_new_popular_terms(affiliate_name)" do
    before do
      ResqueSpec.reset!
    end

    context "when some of the popular terms already have their related searches computed" do
      context "when the affiliate is the default usasearch.gov affiliate" do
        before do
          @crs = calais_related_searches(:usasearch)
          DailyQueryStat.create!(:day => Date.yesterday, :times => 1000, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :query => @crs.term)
          DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :query => "new term")
        end

        it "should enqueue for processing only the new terms" do
          CalaisRelatedSearch.populate_affiliate_with_new_popular_terms(Affiliate::USAGOV_AFFILIATE_NAME)
          CalaisRelatedSearch.should have_queued(Affiliate::USAGOV_AFFILIATE_NAME, "new term")
          CalaisRelatedSearch.should_not have_queued(Affiliate::USAGOV_AFFILIATE_NAME, @crs.term)
        end
      end

      context "when the affiliate is not the default usasearch.gov affiliate" do
        before do
          CalaisRelatedSearch.create!(@valid_attributes)
          DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => @affiliate.name, :query => "SOME new popular term")
          DailyQueryStat.create!(:day => Date.yesterday, :times => 1000, :affiliate => @affiliate.name, :query => "debt relief")
        end

        it "should enqueue for processing only the new terms, normalized to lowercase" do
          CalaisRelatedSearch.populate_affiliate_with_new_popular_terms(@affiliate.name)
          CalaisRelatedSearch.should have_queued(@affiliate.name, "some new popular term")
          CalaisRelatedSearch.should_not have_queued(@affiliate.name, "debt relief")
        end
      end
    end

  end

  describe "#perform(affiliate_name, term)" do
    context "when there are search results for a term" do
      before do
        @term = "pelosi award"
        search = Search.new(:affiliate => @affiliate.name, :query => @term)
        Search.stub!(:new).and_return(search)
        search.stub!(:run).and_return(nil)
        search.stub!(:results).and_return([{'title'=>'First title', 'content' => 'First content'},
                                           {'title'=>'Second title', 'content' => 'Second content'}])
      end

      context "when there are Calais SocialTags for a term's corpus of titles and descriptions" do
        before do
          related_terms = ["congress", "California", "senator", "Pelosi", "Pelosi awards", "Pelosi award"]
          social_tags = related_terms.collect { |rt| OpenStruct.new(:name=> rt) }
          m_calais = mock("calais", :socialtags => social_tags)
          Calais.stub!(:process_document).and_return(m_calais)
        end

        it "should set the CalaisRelatedSearch's English-locale related terms for that term" do
          CalaisRelatedSearch.perform(@affiliate.name, @term)
          CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term, 'en', @affiliate.id).related_terms.should == "congress | california | senator"
        end
      end

      context "when Calais throws a Calais:Error" do
        before do
          Calais.stub!(:process_document).and_raise(Calais::Error)
        end

        it "should log the error" do
          RAILS_DEFAULT_LOGGER.should_receive(:warn).once
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end

      context "when Calais throws a Nokogiri::XML::XPath::SyntaxError" do
        before do
          Calais.stub!(:process_document).and_raise(Nokogiri::XML::XPath::SyntaxError)
        end

        it "should log the error" do
          RAILS_DEFAULT_LOGGER.should_receive(:warn).once
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end

      context "when Calais throws a NoMethodError from some parsing problem" do
        before do
          Calais.stub!(:process_document).and_raise(NoMethodError)
        end

        it "should log the error" do
          RAILS_DEFAULT_LOGGER.should_receive(:warn).once
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end


      context "when Calais throws a date parsing or other argument error" do
        before do
          Calais.stub!(:process_document).and_raise(ArgumentError)
        end

        it "should log the error" do
          RAILS_DEFAULT_LOGGER.should_receive(:warn).once
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end

      context "when Calais service times out" do
        before do
          Calais.stub!(:process_document).and_raise(Curl::Err::TimeoutError)
        end

        it "should log the error" do
          RAILS_DEFAULT_LOGGER.should_receive(:warn).once
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end

    end

  end

  describe "#to_label" do
    it "should return the query term associates with the Calais related search" do
      crs = calais_related_searches(:one)
      crs.to_label.should == crs.term
    end
  end
end
