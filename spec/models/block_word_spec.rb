require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlockWord do
  fixtures :block_words
  before(:each) do
    @valid_attributes = { :word => "Some Block Word" }
  end

  should_validate_presence_of :word
  should_validate_uniqueness_of :word
  should_validate_length_of :word, :within=> (3..50)
  should_not_allow_values_for :word, "citizenship[", "email@address.com", "\"over quoted\""
  should_allow_values_for :word, "my-name", "1099 form"

  it "should create a new instance given valid attributes" do
    BlockWord.create!(@valid_attributes)
  end

  describe "#filter(results, key, number_of_results)" do
    before do
      BlockWord.create!(:word => "foo")
      BlockWord.create!(:word => "blat baz")
      BlockWord.create!(:word => "hyphenate-me")
      queries = ["bar Foo", "bar \xEE\x80\x80Foo\xEE\x80\x81", "bar blat", "blat", "baz blat", "baz loren", "food", "blat <strong>baz</strong>"]
      @results = queries.collect {|q| { "somekey" => q } }
    end

    it "should filter out results that contain blocked terms" do
      filtered_terms = BlockWord.filter(@results, "somekey", 10)
      filtered_terms.size.should == 5
    end

    it "should not filter out queries that contain blocked terms but do not end on a word boundary" do
      filtered_terms = BlockWord.filter(@results, "somekey", 10)
      filtered_terms.detect {|ft| ft["somekey"] == "food" }.should_not be_nil
    end

    it "should handle a nil results list by returning nil" do
      BlockWord.filter(nil, "somekey", 10).should be_nil
    end

    it "should return number_of_results words" do
      BlockWord.filter(@results, "somekey", 3).size.should == 3
    end
  end

end
