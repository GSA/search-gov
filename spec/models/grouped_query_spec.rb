require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupedQuery do
  fixtures :grouped_queries
  before(:each) do
    @valid_attributes = {:query=>"bar"}
  end

  it { should have_and_belong_to_many :query_groups }
  it { should validate_presence_of :query }
  it { should validate_uniqueness_of :query }

  it "should create a new instance given valid attributes" do
    GroupedQuery.create!(@valid_attributes)
  end

  describe "#to_label" do
    it "should return the query for the grouped query" do
      gq = grouped_queries(:query1)
      gq.to_label.should == gq.query
    end
  end
end
