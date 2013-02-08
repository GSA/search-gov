require 'spec_helper'

describe SaytFilter do
  fixtures :sayt_filters

  describe "Creating new instance" do
    it { should validate_presence_of :phrase }
    it { should validate_uniqueness_of :phrase }
    it 'should validate only one of filter_only_exact_phrase and is_regex is true' do
      SaytFilter.new(:phrase => "bAd woRd", :filter_only_exact_phrase => true, :is_regex => true).should_not be_valid
    end

    it "should strip whitespace from phrase before inserting in DB" do
      phrase = " leading and trailing whitespaces "
      sf = SaytFilter.create!(:phrase => phrase, :is_regex => false, :filter_only_exact_phrase => true, :accept => true)
      sf.phrase.should == phrase.strip
      sf.accept.should be_true
      sf.is_regex.should be_false
      sf.filter_only_exact_phrase.should be_true
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

    it "should enqueue the filtering of existing SaytSuggestions via Resque" do
      ResqueSpec.reset!
      Resque.should_receive(:enqueue_with_priority).with(:high, FilterSaytSuggestions, an_instance_of(Fixnum))
      SaytFilter.create!(:phrase => "some valid filter phrase")
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

    context 'when the filter is a regex' do
      let(:filter) { SaytFilter.create!(:phrase => "[^aeiou]\.com", :is_regex => true) }
      it 'should match based on the regex' do
        filter.match?("gotvowels.com").should be_true
        filter.match?("oaeiuXcom").should be_false
      end
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

    context 'when there are exact whitelisted entries' do
      before do
        @queries << 'loren foo bar' << 'loren foo bar blat'
        SaytFilter.create!(:accept => true, :phrase => "loren foo bar", :filter_only_exact_phrase => true)
      end

      it 'should not filter them' do
        SaytFilter.filter(@queries).should include("loren foo bar")
        SaytFilter.filter(@queries).should_not include("loren foo bar blat")
      end
    end

    context 'when there are non-exact whitelisted entries' do
      before do
        @queries << 'loren foo' << 'loren foo bar'
        SaytFilter.create!(:accept => true, :phrase => "loren foo", :filter_only_exact_phrase => false)
      end

      it 'should not filter them' do
        SaytFilter.filter(@queries).should include("loren foo")
        SaytFilter.filter(@queries).should include("loren foo bar")
      end
    end

    context 'when there are regex whitelisted entries' do
      before do
        @queries << 'snafoo' << 'snaxfoo'
        SaytFilter.create!(:accept => true, :phrase => "^.{3}foo", :is_regex => true)
        SaytFilter.create!(:phrase => "foo$", :is_regex => true)
      end

      it 'should not filter them' do
        SaytFilter.filter(@queries).should include("snafoo")
        SaytFilter.filter(@queries).should_not include("snaxfoo")
      end
    end

    context 'when there are only whitelisted filters and no deny filters' do
      before do
        SaytFilter.create!(:accept => true, :phrase => "only once")
      end

      it 'should not create duplicates' do
        SaytFilter.filter(['only once']).should == ['only once']
      end
    end
  end

  describe "#to_label" do
    it "should return the phrase" do
      SaytFilter.new(:phrase => 'dummy filter').to_label.should == 'dummy filter'
    end
  end

end
