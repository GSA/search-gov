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

    it "should squish multiple whitespaces between words in the phrase before entering into DB" do
      SaytFilter.create!(:phrase => "two  spaces")
      SaytFilter.find_by_phrase("two spaces").phrase.should == "two spaces"
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

    it "should Regexp escape the filter before applying it" do
      SaytFilter.create!(:phrase => "ought.")
      SaytSuggestion.find_by_phrase(@phrase).should_not be_nil
    end
  end

  describe "#filter(results, key=nil)" do
    before do
      SaytFilter.create!(:phrase => "foo")
      SaytFilter.create!(:phrase => "blat baz")
      SaytFilter.create!(:phrase => "hyphenate-me")
      SaytFilter.create!(:phrase => "sex.")
      @queries = ["bar Foo", "bar blat", "blat", "baz blat", "baz loren", "food", "sex education"]
      @results = @queries.collect { |q| {"somekey" => q} }
    end

    it "should not filter out queries that contain blocked terms but do not end on a word boundary" do
      filtered_terms = SaytFilter.filter(@results, "somekey")
      filtered_terms.detect { |ft| ft["somekey"] == "food" }.should_not be_nil
    end

    it "should Regexp escape the filter before applying it" do
      filtered_terms = SaytFilter.filter(@results, "somekey")
      filtered_terms.detect { |ft| ft["somekey"] == "sex education" }.should_not be_nil
    end

    context "when results list is nil" do
      it "should return nil" do
        SaytFilter.filter(nil, "somekey").should be_nil
      end
    end

    context "when SaytFilter table is empty" do
      it "should return the same list" do
        SaytFilter.delete_all
        SaytFilter.filter(@results, "somekey").size.should == @results.size
      end
    end

    context "when no key is passed in" do
      it "should operate on raw strings" do
        SaytFilter.filter(@queries).should == SaytFilter.filter(@results, "somekey").collect { |ft| ft["somekey"] }
      end
    end
  end
end
