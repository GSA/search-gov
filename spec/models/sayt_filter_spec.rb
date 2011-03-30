require "#{File.dirname(__FILE__)}/../spec_helper"

describe SaytFilter do
  fixtures :sayt_filters

  describe "Creating new instance" do
    it { should validate_presence_of :phrase }
    it { should validate_uniqueness_of :phrase }
    
    it "should strip whitespace from phrase before inserting in DB" do
      phrase = " leading and trailing whitespaces "
      sf = SaytFilter.create!(:phrase => phrase)
      sf.phrase.should == phrase.strip
    end

    it "should create a new instance given valid attributes" do
      SaytFilter.create!(:phrase => "some valid filter phrase")
    end

    it "should default filter_only_exact_phrase to false" do
      SaytFilter.create!(:phrase => "some filter phrase").filter_only_exact_phrase.should be_false
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

  describe "#match?(target_phrase)" do
    context "when the filter phrase is '.com'" do
      before do
        @filter = SaytFilter.create!(:phrase => ".com")
      end

      it "should filter 'google .com'" do
        @filter.match?("google .com").should be_true
      end

      it "should filter 'google.com'" do
        @filter.match?("google.com").should be_true
      end
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

  context "after saving a SaytFilter with filter_only_exact_entry is true" do
    before do
      @should_be_deleted_phrase = "xxx"
      SaytSuggestion.create!(:phrase => @should_be_deleted_phrase)
      @should_not_be_deleted_phrase = "should not be deleted xxx"
      SaytSuggestion.create!(:phrase => @should_not_be_deleted_phrase)
    end

    it "should run the filter against existing SaytSuggestions" do
      SaytFilter.create!(:phrase => "xxx", :filter_only_exact_phrase => true)
      SaytSuggestion.find_by_phrase(@should_be_deleted_phrase).should be_nil
      SaytSuggestion.find_by_phrase(@should_not_be_deleted_phrase).should_not be_nil
    end
  end

  describe "#filter(results, key=nil)" do
    before do
      SaytFilter.create!(:phrase => "foo")
      SaytFilter.create!(:phrase => "blat baz")
      SaytFilter.create!(:phrase => "hyphenate-me")
      SaytFilter.create!(:phrase => "sex.")
      SaytFilter.create!(:phrase => "bAd woRd", :filter_only_exact_phrase => true)
      @queries = ["bar Foo", "bar blat", "blat", "baz blat", "baz loren", "food", "sex education", "Bad Word", "don't use bad word"]
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

    context "when filter_only_exact_phrase is true" do
      it "should filter exact phrase" do
        filtered_terms = SaytFilter.filter(@results, "somekey")
        filtered_terms.detect { |ft| ft["somekey"] == "bad word" }.should be_nil
      end

      it "should not filter phrase that is part of a longer phrase" do
        filtered_terms = SaytFilter.filter(@results, "somekey")
        filtered_terms.detect { |ft| ft["somekey"] == "don't use bad word" }.should_not be_nil
      end
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

  describe "#to_label" do
    it "should return the phrase" do
      SaytFilter.new(:phrase => 'dummy filter').to_label.should == 'dummy filter'
    end
  end

end
