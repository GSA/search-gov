require "#{File.dirname(__FILE__)}/../spec_helper"

describe SaytSuggestion do
  fixtures :sayt_suggestions, :misspellings, :affiliates
  before(:each) do
    @valid_attributes = {
      :affiliate_id => 370,
      :phrase => "some valid suggestion",
      :popularity => 100
    }
  end

  describe "Creating new instance" do
    should_belong_to :affiliate
    should_validate_presence_of :phrase
    should_validate_uniqueness_of :phrase, :scope => :affiliate_id
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

    it "should default affiliate to null if not specified" do
      SaytSuggestion.create!(:phrase => "popular")
      SaytSuggestion.find_by_phrase("popular").affiliate_id.should be_nil
    end

  end

  describe "#expire(days_back)" do
    it "should delete suggestions that have not been updated in X days" do
      SaytSuggestion.should_receive(:delete_all).with(["updated_at < ?", 30.days.ago.beginning_of_day.to_s(:db)])
      SaytSuggestion.expire(30)
    end
  end

  describe "#populate_for(day)" do
    it "should populate SAYT suggestions for the default affiliate and all affiliates in affiliate table" do
      SaytSuggestion.should_receive(:populate_for_affiliate_on).with(DailyQueryStat::DEFAULT_AFFILIATE_NAME, nil, Date.today)
      Affiliate.all.each do |aff|
        SaytSuggestion.should_receive(:populate_for_affiliate_on).with(aff.name, aff.id, Date.today)
      end
      SaytSuggestion.populate_for(Date.today)
    end
  end

  describe "#populate_for_affiliate_on" do
    context "when no DailyQueryStats exist for the given day for an affiliate" do
      it "should return nil" do
        SaytSuggestion.populate_for_affiliate_on(DailyQueryStat::DEFAULT_AFFILIATE_NAME, nil, Date.today).should be_nil
      end
    end

    context "when DailyQueryStats exist for multiple days for an affiliate" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "yesterday term1", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term1", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term2", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      end

      it "should populate SaytSuggestions based on each DailyQueryStat for the given day" do
        SaytSuggestion.populate_for_affiliate_on(DailyQueryStat::DEFAULT_AFFILIATE_NAME, nil, Date.today)
        SaytSuggestion.find_by_affiliate_id_and_phrase_and_popularity(nil, "today term1", 2).should_not be_nil
        SaytSuggestion.find_by_affiliate_id_and_phrase_and_popularity(nil, "today term2", 2).should_not be_nil
        SaytSuggestion.find_by_phrase("yesterday term1").should be_nil
      end
    end

    context "when SaytFilters exist" do
      before do
        @affiliate = affiliates(:power_affiliate)
        DailyQueryStat.create!(:day => Date.today, :query => "today term1", :times => 2, :affiliate => @affiliate.name)
        DailyQueryStat.create!(:day => Date.today, :query => "today term2", :times => 2, :affiliate => @affiliate.name)
        SaytFilter.create!(:phrase => "term2")
      end

      it "should apply SaytFilters to each eligible DailyQueryStat word" do
        SaytSuggestion.populate_for_affiliate_on(@affiliate.name, @affiliate.id, Date.today)
        SaytSuggestion.find_by_affiliate_id_and_phrase(@affiliate.id, "today term2").should be_nil
      end
    end

    context "when SaytSuggestion already exists for an affiliate" do
      before do
        @affiliate = affiliates(:power_affiliate)
        SaytSuggestion.create!(:phrase => "already here", :popularity => 10, :affiliate_id => @affiliate.id)
        DailyQueryStat.create!(:day => Date.today, :query => "already here", :times => 2, :affiliate => @affiliate.name)
      end

      it "should update the popularity field with the new count" do
        SaytSuggestion.populate_for_affiliate_on(@affiliate.name, @affiliate.id, Date.today)
        SaytSuggestion.find_by_affiliate_id_and_phrase(@affiliate.id, "already here").popularity.should == 2
      end
    end
  end

  describe "#like(affiliate_id, query, num_suggestions)" do
    before do
      @affiliate = affiliates(:power_affiliate)
    end

    context "when affiliate_id is nil" do
      before do
        SaytSuggestion.create!(:phrase => "child", :popularity => 10, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "child default", :popularity => 100)
        @array = SaytSuggestion.like(nil, "child", 10)
      end

      it "should return records for affiliate_id is null" do
        @array.size.should == 1
        @array.first.phrase.should == "child default"
      end
    end

    context "when affiliate_id is specified" do
      before do
        SaytSuggestion.create!(:phrase => "child", :popularity => 10, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "child care", :popularity => 1, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "children", :popularity => 100, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "child default", :popularity => 100)
        @array = SaytSuggestion.like(@affiliate.id, "child", 10)
      end

      it "should return records for that affiliate_id" do
        @array.size.should == 3
      end
    end

    context "when there are more than num_suggestions results available" do
      before do
        SaytSuggestion.create!(:phrase => "child", :popularity => 10, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "child care", :popularity => 1, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "children", :popularity => 100, :affiliate_id => @affiliate.id)
        @array = SaytSuggestion.like(@affiliate.id, "child", 2)
      end

      it "should return at most num_suggestions results" do
        @array.size.should == 2
      end
    end

    context "when there are multiple suggestions available" do
      before do
        SaytSuggestion.create!(:phrase => "child", :popularity => 10, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "child care", :popularity => 1, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "children", :popularity => 100, :affiliate_id => @affiliate.id)
        @array = SaytSuggestion.like(@affiliate.id, "child", 10)
      end

      it "should return an array of SAYT suggestions" do
        @array.class.should == Array
        @array.each do |phrase|
          phrase.class.should == SaytSuggestion
        end
      end

      it "should return results in order of popularity" do
        @array.first.phrase.should == "children"
        @array.last.phrase.should == "child care"
      end
    end
  end
end
