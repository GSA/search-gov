require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe CalaisRelatedSearch do
  fixtures :calais_related_searches

  before(:each) do
    @valid_attributes = {
      :term => "debt relief",
      :related_terms => "Personal finance | United States bankruptcy law | Mortgage Forgiveness Debt Relief Act"
    }
  end

  it "should create a new instance given valid attributes" do
    CalaisRelatedSearch.create!(@valid_attributes)
  end

  should_validate_presence_of :term, :related_terms
  should_validate_uniqueness_of :term

  describe "#populate_with_new_popular_terms" do
    context "when some of the popular terms already have their related searches computed" do
      before do
        CalaisRelatedSearch.create!(@valid_attributes)
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1001, :query => "SOME new popular term", :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1000, :query => "debt relief", :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      end

      it "should call related_terms_for() with only the new terms, normalized to lowercase" do
        CalaisRelatedSearch.should_receive(:related_terms_for).once.with("some new popular term")
        CalaisRelatedSearch.populate_with_new_popular_terms
      end

    end
  end

  describe "#related_terms_for(term)" do
    context "when there are search results for a term" do
      before do
        @term = "pelosi award"
        search = Search.new(:query => @term)
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

        it "should set the CalaisRelatedSearch's related terms for that term" do
          CalaisRelatedSearch.related_terms_for(@term)
          CalaisRelatedSearch.find_by_term(@term).related_terms.should == "congress | california | senator"
        end
      end

      context "when Calais throws an error" do
        before do
          Calais.stub!(:process_document).and_raise(Calais::Error)
        end

        it "should log the error" do
          RAILS_DEFAULT_LOGGER.should_receive(:warn).once
          CalaisRelatedSearch.related_terms_for(@term)
        end
      end

    end

  end

end
