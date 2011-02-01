require "#{File.dirname(__FILE__)}/../spec_helper"

describe SaytSuggestion do
  fixtures :sayt_suggestions, :misspellings, :affiliates
  before(:each) do
    @valid_attributes = {
      :affiliate_id => affiliates(:power_affiliate).id,
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
                                "http:something", "site:something", "intitle:something", "passports'", ".mp3", "' pictures"
    should_allow_values_for :phrase, "basic phrase", "my-name", "1099 form", "Senator Frank S. Farley State Marina", "Oswald West State Park's Smuggler Cove", "en español"

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

  describe "#prune_dead_ends" do
    before do
      SaytSuggestion.delete_all
      one = SaytSuggestion.create!(:phrase => "yosemite", :affiliate_id => affiliates(:basic_affiliate).id)
      two = SaytSuggestion.create!(:phrase => "prune me")
      Search.should_receive(:results_present_for?).with(one.phrase, affiliates(:basic_affiliate)).and_return true
      Search.should_receive(:results_present_for?).with(two.phrase, nil).and_return false
    end

    it "should delete suggestions that yield no search results" do
      SaytSuggestion.prune_dead_ends
      SaytSuggestion.count.should == 1
      SaytSuggestion.first.phrase.should == "yosemite"
    end
  end

  describe "#populate_for(day)" do
    it "should populate SAYT suggestions for the default affiliate and all affiliates in affiliate table" do
      SaytSuggestion.should_receive(:populate_for_affiliate_on).with(Affiliate::USAGOV_AFFILIATE_NAME, nil, Date.today)
      Affiliate.all.each do |aff|
        SaytSuggestion.should_receive(:populate_for_affiliate_on).with(aff.name, aff.id, Date.today)
      end
      SaytSuggestion.populate_for(Date.today)
    end
  end

  describe "#populate_for_affiliate_on(affiliate_name, affiliate_id, day)" do
    before do
      ResqueSpec.reset!
    end

    it "should enqueue the affiliate for processing" do
      aff = affiliates(:basic_affiliate)
      SaytSuggestion.populate_for_affiliate_on(aff.name, aff.id, Date.today)
      SaytSuggestion.should have_queued(aff.name, aff.id, Date.today)
    end
  end

  describe "#perform(affiliate_name, affiliate_id, day)" do
    context "when no DailyQueryStats exist for the given day for an affiliate" do
      it "should return nil" do
        SaytSuggestion.perform(Affiliate::USAGOV_AFFILIATE_NAME, nil, Date.today).should be_nil
      end
    end

    context "when DailyQueryStats exist for multiple days for an affiliate" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "yesterday term1", :times => 2, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term1", :times => 2, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.today, :query => "today term2", :times => 2, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        Search.stub!(:results_present_for?).and_return true
      end

      it "should populate SaytSuggestions based on each DailyQueryStat for the given day" do
        SaytSuggestion.perform(Affiliate::USAGOV_AFFILIATE_NAME, nil, Date.today)
        SaytSuggestion.find_by_affiliate_id_and_phrase_and_popularity(nil, "today term1", 2).should_not be_nil
        SaytSuggestion.find_by_affiliate_id_and_phrase_and_popularity(nil, "today term2", 2).should_not be_nil
        SaytSuggestion.find_by_phrase("yesterday term1").should be_nil
      end
    end

    context "when search results with no Bing spelling suggestions are present for only some query/affiliate pairs" do
      before do
        @one = DailyQueryStat.create!(:day => Date.today, :query => "no results for this query, or got a spelling correction", :times => 2, :affiliate => affiliates(:basic_affiliate).name)
        @two = DailyQueryStat.create!(:day => Date.today, :query => "got results with no spelling suggestion for this query", :times => 2, :affiliate => affiliates(:basic_affiliate).name)
        Search.should_receive(:results_present_for?).with(@one.query, affiliates(:basic_affiliate), false).and_return false
        Search.should_receive(:results_present_for?).with(@two.query, affiliates(:basic_affiliate), false).and_return true
      end

      it "should only create SaytSuggestions for the ones with results" do
        SaytSuggestion.perform(affiliates(:basic_affiliate).name, affiliates(:basic_affiliate).id, Date.today)
        SaytSuggestion.find_by_phrase(@one.query).should be_nil
        SaytSuggestion.find_by_phrase(@two.query).should_not be_nil
      end
    end

    context "when DailyQueryStats exist for multiple locales for an affiliate" do
      before do
        DailyQueryStat.create!(:day => Date.today, :query => "el paso", :times => 2, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale=>'es')
        DailyQueryStat.create!(:day => Date.today, :query => "el paso", :times => 4, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale=>'en')
        Search.stub!(:results_present_for?).and_return true
      end

      it "should combine data from all locales to populate SaytSuggestions" do
        SaytSuggestion.perform(Affiliate::USAGOV_AFFILIATE_NAME, nil, Date.today)
        SaytSuggestion.find_by_affiliate_id_and_phrase(nil, "el paso").popularity.should == 6
      end
    end

    context "when SaytFilters exist" do
      before do
        @affiliate = affiliates(:power_affiliate)
        DailyQueryStat.create!(:day => Date.today, :query => "today term1", :times => 2, :affiliate => @affiliate.name)
        DailyQueryStat.create!(:day => Date.today, :query => "today term2", :times => 2, :affiliate => @affiliate.name)
        SaytFilter.create!(:phrase => "term2")
        Search.stub!(:results_present_for?).and_return true
      end

      it "should apply SaytFilters to each eligible DailyQueryStat word" do
        SaytSuggestion.perform(@affiliate.name, @affiliate.id, Date.today)
        SaytSuggestion.find_by_affiliate_id_and_phrase(@affiliate.id, "today term2").should be_nil
      end
    end

    context "when SaytSuggestion already exists for an affiliate" do
      before do
        @affiliate = affiliates(:power_affiliate)
        SaytSuggestion.create!(:phrase => "already here", :popularity => 10, :affiliate_id => @affiliate.id)
        DailyQueryStat.create!(:day => Date.today, :query => "already here", :times => 2, :affiliate => @affiliate.name)
        Search.stub!(:results_present_for?).and_return true
      end

      it "should update the popularity field with the new count" do
        SaytSuggestion.perform(@affiliate.name, @affiliate.id, Date.today)
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

    context "when multiple suggestions have the same popularity" do
      before do
        SaytSuggestion.create!(:phrase => "eliz hhh", :popularity => 100, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "eliz aaa", :popularity => 100, :affiliate_id => @affiliate.id)
        SaytSuggestion.create!(:phrase => "eliz ggg", :popularity => 100, :affiliate_id => @affiliate.id)
      end

      it "should return results in alphabetical order" do
        @array = SaytSuggestion.like(@affiliate.id, "eliz", 3)
        @array.first.phrase.should == "eliz aaa"
        @array.last.phrase.should == "eliz hhh"
      end
    end
  end

  describe "#process_sayt_suggestion_txt_upload" do
    fixtures :affiliates
    before do
      @affiliate = affiliates(:basic_affiliate)
      @phrases = %w{ one two three }
      @file = ActionController::TestUploadedFile.new('spec/fixtures/txt/sayt_suggestions.txt', 'text/plain')
      @file.open
      @dummy_suggestion = SaytSuggestion.create(:phrase => 'dummy suggestions')
    end

    it "should create SAYT suggestions using the affiliate provided, if provided" do
      @phrases.each do |phrase|
        SaytSuggestion.should_receive(:create).with({:phrase => phrase, :affiliate => @affiliate}).and_return @dummy_suggestion
      end
      SaytSuggestion.process_sayt_suggestion_txt_upload(@file, @affiliate)
    end

    it "should create SAYT suggestions without an affiliate if none is provided" do
      @phrases.each do |phrase|
        SaytSuggestion.should_receive(:create).with(:phrase => phrase, :affiliate => nil).and_return @dummy_suggestion
      end
      SaytSuggestion.process_sayt_suggestion_txt_upload(@file)
    end
  end
end
