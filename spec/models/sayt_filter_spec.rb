require "#{File.dirname(__FILE__)}/../spec_helper"

describe SaytFilter do
  fixtures :sayt_filters

  describe "Creating new instance" do
    should_validate_presence_of :phrase
    should_validate_uniqueness_of :phrase
    it "should strip whitespace from phrase before inserting in DB" do
      phrase = " leading and trailing whitespaces "
      sf = SaytFilter.create!(:phrase => phrase)
      sf.phrase.should == phrase.strip
    end

    it "should create a new instance given valid attributes" do
      SaytFilter.create!(:phrase => "some valid filter phrase")
    end

    it "should downcase the phrase before entering into DB" do
      SaytFilter.create!(:phrase => "ALL CAPS")
      SaytFilter.find_by_phrase("all caps").phrase.should == "all caps"
    end

  end

  context "after saving a SaytFilter" do
    before do
      @phrase = "ought to get deleted xxx"
      SaytSuggestion.create!(:phrase => @phrase)
    end

    it "should run the filter against existing SaytSuggestions" do
      SaytFilter.create!(:phrase => "xxx")
      SaytSuggestion.find_by_phrase(@phrase).should be_nil
    end
  end

  describe "#filter(results, key)" do
    before do
      SaytFilter.create!(:phrase => "foo")
      SaytFilter.create!(:phrase => "blat baz")
      SaytFilter.create!(:phrase => "hyphenate-me")
      queries = ["bar Foo", "bar blat", "blat", "baz blat", "baz loren", "food"]
      @results = queries.collect {|q| { "somekey" => q } }
    end

    it "should not filter out queries that contain blocked terms but do not end on a word boundary" do
      filtered_terms = SaytFilter.filter(@results, "somekey")
      filtered_terms.detect {|ft| ft["somekey"] == "food" }.should_not be_nil
    end

    it "should handle a nil results list by returning nil" do
      SaytFilter.filter(nil, "somekey").should be_nil
    end

    it "should handle an empty SaytFilter table" do
      SaytFilter.delete_all
      SaytFilter.filter(@results, "somekey").size.should == @results.size
    end
  end
end
