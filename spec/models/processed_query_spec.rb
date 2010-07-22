require 'spec_helper'

describe ProcessedQuery do
  before(:each) do
    @valid_attributes = {
      :query => 'barack obama',
      :affiliate => 'usasearch.gov',
      :day => Date.today,
      :times => 20
    }
  end
  
  should_validate_presence_of :query, :affiliate, :day, :times
  should_validate_numericality_of :times

  it "should create a new instance given valid attributes" do
    ProcessedQuery.create!(@valid_attributes)
  end
  
  describe "#related_to" do
    before do
      ProcessedQuery.create!(@valid_attributes.merge(:query => 'barack h. obama'))
      ProcessedQuery.create!(@valid_attributes.merge(:query => 'barack obama'))      
      Sunspot.commit
    end
    
    it "should return results that are similar to the query specified" do
      ProcessedQuery.related_to('obama').total.should == 2
    end
  end
end
