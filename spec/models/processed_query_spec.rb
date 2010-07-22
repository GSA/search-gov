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

  it "should create a new instance given valid attributes" do
    ProcessedQuery.create!(@valid_attributes)
  end
end
