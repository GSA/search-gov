require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupedQuery do
  fixtures :grouped_queries
  before(:each) do
    @valid_attributes = {:query=>"bar"}
  end

  should_have_and_belong_to_many :query_groups

  should_validate_presence_of :query
  should_validate_uniqueness_of :query

  it "should create a new instance given valid attributes" do
    GroupedQuery.create!(@valid_attributes)
  end
end
