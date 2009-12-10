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

end
