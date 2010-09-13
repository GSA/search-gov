require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QueryGroup do
  fixtures :query_groups
  before(:each) do
    @valid_attributes = {:name=>"foo"}
  end

  should_have_and_belong_to_many :grouped_queries, :order => 'query ASC'
  should_validate_presence_of :name
  should_validate_uniqueness_of :name

  it "should create a new instance given valid attributes" do
    QueryGroup.create!(@valid_attributes)
  end

end
