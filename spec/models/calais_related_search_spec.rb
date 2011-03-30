require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe CalaisRelatedSearch do
  fixtures :affiliates, :calais_related_searches

  before(:each) do
    @redis = CalaisRelatedSearch.send(:class_variable_get, :@@redis)
    @affiliate = affiliates(:power_affiliate)
    @valid_attributes = {
      :affiliate => @affiliate,
      :term => "debt relief",
      :related_terms => "Personal finance | United States bankruptcy law | Mortgage Forgiveness Debt Relief Act",
      :locale => 'en',
      :gets_refreshed => true
    }
  end

  describe "#delete_if_exists(term, locale, affiliate_id)" do
    context "when a CalaisRelatedSearch exists matching the given term, locale, and affilaite_id" do
      it "should delete the CalaisRelatedSearch" do
        crs = calais_related_searches(:ups)
        CalaisRelatedSearch.delete_if_exists(crs.term, crs.locale, crs.affiliate.id)
        CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(crs.term, crs.locale, crs.affiliate.id).should be_false
      end
    end
  end

  describe "#prune_dead_ends" do
    context "when the pivot term has no search results" do
      before do
        @ups = calais_related_searches(:ups)
        @potus = calais_related_searches(:potus)
        Search.stub!(:results_present_for?).and_return true
        Search.should_receive(:results_present_for?).with(@potus.term, nil).and_return false
      end

      it "should delete the CalaisRelatedSearches that yield no search results for the pivot term" do
        CalaisRelatedSearch.prune_dead_ends
        CalaisRelatedSearch.exists?(:term => @ups.term).should be_true
        CalaisRelatedSearch.exists?(:term => @potus.term).should be_false
      end
    end

    context "when one of the related terms yields no search results" do
      before do
        @potus = calais_related_searches(:potus)
        @dead_term = "oval office"
        Search.stub!(:results_present_for?).and_return true
        Search.should_receive(:results_present_for?).with(@dead_term, nil).and_return false
      end

      it "should delete the related term from the group" do
        CalaisRelatedSearch.find_by_term(@potus.term).related_terms.should match(/#{@dead_term}/)
        CalaisRelatedSearch.prune_dead_ends
        CalaisRelatedSearch.find_by_term(@potus.term).related_terms.should_not match(/#{@dead_term}/)
      end
    end

    context "when all of the related terms yield no search results but the pivot term does yield results" do
      before do
        calais_related_searches(:ups).delete
        potus = calais_related_searches(:potus)
        Search.stub!(:results_present_for?).and_return false
        Search.should_receive(:results_present_for?).with(potus.term, nil).and_return true
      end

      it "should delete the CalaisRelatedSearch entry altogether" do
        CalaisRelatedSearch.count.should > 0
        CalaisRelatedSearch.prune_dead_ends
        CalaisRelatedSearch.count.should be_zero
      end
    end
  end

  context "when creating a new instance" do
    it "should create a new instance given valid attributes" do
      CalaisRelatedSearch.create!(@valid_attributes)
    end

    it "should default to being protected from automatic refreshes" do
      crs = CalaisRelatedSearch.create!(:term => "debt relief", :related_terms => "whatevs")
      crs.gets_refreshed.should be_false
    end

    it { should validate_presence_of :term }
    it { should validate_presence_of :related_terms }
    it { should validate_presence_of :locale }
    it { should validate_uniqueness_of(:term).scoped_to([:affiliate_id, :locale]) }
    SUPPORTED_LOCALES.each do |value|
      it { should allow_value(value).for(:locale) }
    end
    it { should belong_to :affiliate }
  end

  describe "#refresh_stalest_entries" do
    before do
      ResqueSpec.reset!
      CalaisRelatedSearch.stub!(:daily_api_quota).and_return(2)
      CalaisRelatedSearch.delete_all
      a = CalaisRelatedSearch.create!(:affiliate => @affiliate, :term => "term1", :related_terms => "rs1 | rs2 | rs3", :locale => 'en')
      b = CalaisRelatedSearch.create!(:affiliate => nil, :term => "term2", :related_terms => "rs4 | rs5 | rs6", :locale => 'en')
      CalaisRelatedSearch.create!(:affiliate => @affiliate, :term => "term3", :related_terms => "rs7 | rs8 | rs9", :locale => 'en')
      @oldest_two = [a, b]
    end

    it "should refresh the oldest refreshable English entries up to the daily API quota limit" do
      @redis.should_receive(:incr).twice.and_return(1, 2)
      CalaisRelatedSearch.should_receive(:find_all_by_locale_and_gets_refreshed).with('en', true, :order => 'updated_at', :limit => 2).and_return @oldest_two
      CalaisRelatedSearch.refresh_stalest_entries
      CalaisRelatedSearch.should have_queued(@affiliate.name, "term1")
      CalaisRelatedSearch.should have_queued(Affiliate::USAGOV_AFFILIATE_NAME, "term2")
      CalaisRelatedSearch.should_not have_queued(@affiliate.name, "term3")
    end
  end

  describe "#populate_with_new_popular_terms" do
    before do
      @second_affiliate = affiliates(:basic_affiliate)
    end

    context "when some affiliates got searches yesterday" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => @affiliate.name, :query => "SOME new popular term")
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => @second_affiliate.name, :query => "SOME new popular term")
        @redis.stub!(:get).and_return(1, 2)
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
        @redis = CalaisRelatedSearch.send(:class_variable_get, :@@redis)
        DailyQueryStat.create!(:affiliate => @second_affiliate.name, :day => Date.yesterday, :times => 1000, :query => "first one")
        DailyQueryStat.create!(:affiliate => @affiliate.name, :day => Date.yesterday, :times => 1000, :query => "second one")
        DailyQueryStat.create!(:affiliate => @affiliate.name, :day => Date.yesterday, :times => 1000, :query => "third one")
      end

      it "should only enqueue up to the limit" do
        @redis.should_receive(:incr).twice.and_return(1, 2)
        @redis.should_receive(:get).twice.and_return("1", "2")
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
          @crs = calais_related_searches(:potus)
          DailyQueryStat.create!(:day => Date.yesterday, :times => 1000, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :query => @crs.term)
          DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :query => "new term")
          @redis.stub!(:incr).and_return(1, 2)
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
          @redis.stub!(:incr).and_return(1, 2)
        end

        it "should enqueue for processing only the new terms" do
          CalaisRelatedSearch.populate_affiliate_with_new_popular_terms(@affiliate.name)
          CalaisRelatedSearch.should have_queued(@affiliate.name, "SOME new popular term")
          CalaisRelatedSearch.should_not have_queued(@affiliate.name, "debt relief")
        end
      end
    end

  end

  describe "#perform(affiliate_name, term)" do
    context "when there are no search results for a term" do
      before do
        @term = "no results found here"
        search = Search.new(:affiliate => @affiliate.name, :query => @term)
        Search.stub!(:new).and_return(search)
        search.stub!(:run)
        search.stub!(:results).and_return([])
      end

      it "should attempt to delete any existing record for that affiliate and term" do
        CalaisRelatedSearch.should_receive(:delete_if_exists).with(@term, 'en', @affiliate.id)
        CalaisRelatedSearch.perform(@affiliate.name, @term)
      end
    end

    context "when there are search results for a term" do
      before do
        @term = "pelosi award"
        search = Search.new(:affiliate => @affiliate.name, :query => @term)
        Search.stub!(:new).and_return(search)
        search.stub!(:run).and_return(nil)
        search.stub!(:results).and_return([{'title'=>'First title', 'content' => 'First content'},
                                           {'title'=>'Second title', 'content' => 'Second content'}])
        Search.stub!(:results_present_for?).and_return true
      end

      context "when there are no Calais SocialTags for a term's corpus of titles and descriptions" do
        before do
          Calais.stub!(:process_document).and_return(mock("calais", :socialtags => []))
        end

        it "should attempt to delete any existing record for that affiliate and term" do
          CalaisRelatedSearch.should_receive(:delete_if_exists).with(@term, 'en', @affiliate.id)
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end

      context "when there are duplicate (ignoring case) Calais SocialTags" do
        before do
          related_terms = ["congress", "California", "CIA inquiry", "Congress"]
          social_tags = related_terms.collect { |rt| OpenStruct.new(:name=> rt) }
          m_calais = mock("calais", :socialtags => social_tags)
          Calais.stub!(:process_document).and_return(m_calais)
        end

        it "should dedupe them" do
          CalaisRelatedSearch.perform(@affiliate.name, @term)
          CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term, 'en', @affiliate.id).related_terms.should == "California | CIA inquiry | Congress"
        end
      end

      context "when there are Calais SocialTags for a term's corpus of titles and descriptions" do
        before do
          related_terms = ["congress", "California", "CIA inquiry", "Pelosi", "Pelosi awards", "Pelosi award", "really bad offensiveterm"]
          social_tags = related_terms.collect { |rt| OpenStruct.new(:name=> rt) }
          m_calais = mock("calais", :socialtags => social_tags)
          Calais.stub!(:process_document).and_return(m_calais)
          SaytFilter.create!(:phrase=> "offensiveterm")
        end

        it "should set the CalaisRelatedSearch's English-locale related terms for that term" do
          CalaisRelatedSearch.perform(@affiliate.name, @term)
          CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term, 'en', @affiliate.id).related_terms.should == "congress | California | CIA inquiry"
        end

        it "should set the CalaisRelatedSearch's gets_refreshed flag to true for that term" do
          CalaisRelatedSearch.perform(@affiliate.name, @term)
          CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term, 'en', @affiliate.id).gets_refreshed.should be_true
        end

        context "when a SocialTag doesn't have any search results associated with it for that affiliate" do
          before do
            Search.should_receive(:results_present_for?).with("congress", @affiliate).and_return false
          end

          it "should not include that SocialTag in the set of related terms for that pivot term" do
            CalaisRelatedSearch.perform(@affiliate.name, @term)
            CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term, 'en', @affiliate.id).related_terms.should == "California | CIA inquiry"
          end
        end
      end

      context "when there's an existing and differently-cased CalaisRelatedSearch to be updated" do
        before do
          CalaisRelatedSearch.create!(:term=> @term.upcase, :locale=>'en', :affiliate_id => @affiliate.id, :related_terms => "congress | California | CIA inquiry")
          related_terms = ["totally", "new", "terms"]
          social_tags = related_terms.collect { |rt| OpenStruct.new(:name=> rt) }
          m_calais = mock("calais", :socialtags => social_tags)
          Calais.stub!(:process_document).and_return(m_calais)
        end

        it "should update the CalaisRelatedSearch's English-locale related terms for that term" do
          CalaisRelatedSearch.perform(@affiliate.name, @term)
          CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term, 'en', @affiliate.id).related_terms.should == "totally | new | terms"
          CalaisRelatedSearch.find_by_term_and_locale_and_affiliate_id(@term.upcase, 'en', @affiliate.id).related_terms.should == "totally | new | terms"
        end
      end

      context "when Calais throws an error while processing a request for social tags" do
        before do
          Calais.stub!(:process_document).and_raise(StandardError)
        end

        it "should log the error" do
          Rails.logger.should_receive(:warn).once
          CalaisRelatedSearch.perform(@affiliate.name, @term)
        end
      end

    end

  end

  describe "#to_label" do
    it "should return the query term associates with the Calais related search" do
      crs = calais_related_searches(:ups)
      crs.to_label.should == crs.term
    end
  end
end
