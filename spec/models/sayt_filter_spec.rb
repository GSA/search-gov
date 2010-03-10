require "#{File.dirname(__FILE__)}/../spec_helper"

describe SaytFilter do
  fixtures :sayt_filters

  describe "Creating new instance" do
    should_validate_presence_of :phrase
    should_validate_uniqueness_of :phrase

    it "should create a new instance given valid attributes" do
      valid_attributes = { :phrase => "some valid filter phrase" }
      SaytFilter.create!(valid_attributes)
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
      queries = ["bar Foo", "bar \xEE\x80\x80Foo\xEE\x80\x81", "bar blat", "blat", "baz blat", "baz loren", "food", "blat <strong>baz</strong>"]
      @results = queries.collect {|q| { "somekey" => q } }
    end

    it "should filter out results stripped of highlighting that contain blocked terms" do
      filtered_terms = SaytFilter.filter(@results, "somekey")
      filtered_terms.size.should == 5
    end

    it "should not filter out queries that contain blocked terms but do not end on a word boundary" do
      filtered_terms = SaytFilter.filter(@results, "somekey")
      filtered_terms.detect {|ft| ft["somekey"] == "food" }.should_not be_nil
    end

    it "should handle a nil results list by returning nil" do
      SaytFilter.filter(nil, "somekey").should be_nil
    end
  end
end
