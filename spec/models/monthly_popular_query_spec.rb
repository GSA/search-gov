require "#{File.dirname(__FILE__)}/../spec_helper"

describe MonthlyPopularQuery do
  fixtures :monthly_popular_queries

  before do
    @valid_attributes = {
      :year => 2011,
      :month => 3,
      :query => "america",
      :is_grouped => false,
      :times => 100
    }
  end

  describe "creating a new instance" do
    should_validate_presence_of :year, :month, :query, :times
    should_validate_uniqueness_of :query, :scope => [:year, :month, :is_grouped]

    it "should default to not grouped" do
      MonthlyPopularQuery.new.is_grouped.should be_false
    end
  end
end
