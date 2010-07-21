require 'spec_helper'

describe RelatedQuery do
  before(:each) do
    @valid_attributes = {
     :query => "barack obama",
     :related_query => "joe biden",
     :score => 1.0
    }
  end
  
  should_validate_presence_of :query, :related_query, :score
  should_validate_numericality_of :score

  it "should create a new instance given valid attributes" do
    RelatedQuery.create!(@valid_attributes)
  end
  
  it "should downcase the query and related query before saving" do
    related_query = RelatedQuery.create(:query => "Barack Obama", :related_query => "Joe Biden", :score => 1.0)
    related_query.query.should == "barack obama"
    related_query.related_query.should == "joe biden"
  end
end
