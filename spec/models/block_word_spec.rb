require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlockWord do
  fixtures :block_words
  before(:each) do
    @valid_attributes = { :word => "Some Block Word" }
  end

  should_validate_presence_of :word
  should_validate_uniqueness_of :word

  it "should create a new instance given valid attributes" do
    BlockWord.create!(@valid_attributes)
  end

  describe "#filter(results, key)" do
    before do
      BlockWord.create(:word => "foo")
      BlockWord.create(:word => "blat baz")
      queries = ["bar foo", "bar blat", "blat", "baz blat", "baz loren", "food", "blat <strong>baz</strong>"]
      @results = queries.collect {|q| { "somekey" => q } }
    end

    it "should filter out results that contain blocked terms" do
      filtered_terms = BlockWord.filter(@results, "somekey")
      filtered_terms.detect {|ft| ft["somekey"] == "bar foo" }.should be_nil
      filtered_terms.detect {|ft| ft["somekey"] == "blat <strong>baz</strong>" }.should be_nil
    end

    it "should not filter out queries that contain blocked terms but do not end on a word boundary" do
      filtered_terms = BlockWord.filter(@results, "somekey")
      filtered_terms.detect {|ft| ft["somekey"] == "food" }.should_not be_nil
    end

    it "should handle a nil results list by returning nil" do
      BlockWord.filter(nil, "somekey").should be_nil
    end
  end

end
