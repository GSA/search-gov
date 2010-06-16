require "#{File.dirname(__FILE__)}/../spec_helper"

describe SaytSuggestion do
  fixtures :sayt_suggestions, :misspellings
  before(:each) do
    @valid_attributes = {
      :phrase => "some valid suggestion",
      :popularity => 100
    }
  end

  describe "Creating new instance" do
    should_validate_presence_of :phrase
    should_validate_uniqueness_of :phrase
    should_validate_length_of :phrase, :within=> (3..80)
    should_not_allow_values_for :phrase, "citizenship[", "email@address.com", "\"over quoted\"", "colon: here",
                                "http:something", "site:something", "intitle:something",
                                "en español", "passports'", ".mp3", "' pictures"
    should_allow_values_for :phrase, "basic phrase", "my-name", "1099 form", "Senator Frank S. Farley State Marina", "Oswald West State Park's Smuggler Cove"

    it "should create a new instance given valid attributes" do
      SaytSuggestion.create!(@valid_attributes)
    end

    it "should downcase the phrase before entering into DB" do
      SaytSuggestion.create!(:phrase => "ALL CAPS")
      SaytSuggestion.find_by_phrase("all caps").phrase.should == "all caps"
    end

    it "should strip whitespace from phrase before inserting in DB" do
      phrase = " leading and trailing whitespaces "
      sf = SaytSuggestion.create!(:phrase => phrase)
      sf.phrase.should == phrase.strip
    end

    it "should squish multiple whitespaces between words in the phrase before entering into DB" do
      SaytSuggestion.create!(:phrase => "two  spaces")
      SaytSuggestion.find_by_phrase("two spaces").phrase.should == "two spaces"
    end

    it "should correct misspellings before entering in DB" do
      SaytSuggestion.create!(:phrase => "barack ubama")
      SaytSuggestion.find_by_phrase("barack obama").should_not be_nil
    end

    it "should default popularity to 1 if not specified" do
      SaytSuggestion.create!(:phrase => "popular")
      SaytSuggestion.find_by_phrase("popular").popularity.should == 1
    end

  end

  describe "#expire(days_back)" do
    it "should delete suggestions that have not been updated in X days" do
      SaytSuggestion.should_receive(:delete_all).with(["updated_at < ?", 30.days.ago.to_s(:db)])
      SaytSuggestion.expire(30)
    end
  end

  describe "#populate_for(day)" do
    context "when no DailyQueryStats exist for the given day" do
      it "should return nil" do
        SaytSuggestion.populate_for(Date.today).should be_nil
      end
    end

    context "when DailyQueryStats exist for multiple days" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "yesterday term1", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term1", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term2", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      end

      it "should populate SaytSuggestions based on each DailyQueryStat for the given day" do
        SaytSuggestion.populate_for(Date.today)
        SaytSuggestion.find_by_phrase_and_popularity("today term1", 2).should_not be_nil
        SaytSuggestion.find_by_phrase_and_popularity("today term2", 2).should_not be_nil
        SaytSuggestion.find_by_phrase("yesterday term1").should be_nil
      end
    end

    context "when SaytFilters exist" do
      before do
        DailyQueryStat.create!(:day => Date.today, :query => "today term1", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term2", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        SaytFilter.create!(:phrase => "term2")
      end

      it "should apply SaytFilters to each eligible DailyQueryStat word" do
        SaytSuggestion.populate_for(Date.today)
        SaytSuggestion.find_by_phrase("today term2").should be_nil
      end
    end

    context "when SaytSuggestion already exists" do
      before do
        SaytSuggestion.create!(:phrase => "already here", :popularity => 10)
        DailyQueryStat.create!(:day => Date.today, :query => "already here", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      end

      it "should increment the popularity field appropriately" do
        SaytSuggestion.populate_for(Date.today)
        SaytSuggestion.find_by_phrase("already here").popularity.should == 12
      end
    end
  end
end
