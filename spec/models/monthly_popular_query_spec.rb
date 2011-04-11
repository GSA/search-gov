require "#{File.dirname(__FILE__)}/../spec_helper"

describe MonthlyPopularQuery do
  before do
    @valid_attributes = {
      :year => 2011,
      :month => 3,
      :query => "america",
      :times => 100
    }
  end
  
  describe "creating a new instance" do
    before do
      @monthly_popular_query = MonthlyPopularQuery.create(@valid_attributes)
    end
      
    should_validate_presence_of :year, :month, :query, :times
    should_validate_uniqueness_of :query, :scope => [:year, :month]
  
    it "should default the to not grouped" do
      @monthly_popular_query.is_grouped.should be_false
    end
  end
end
