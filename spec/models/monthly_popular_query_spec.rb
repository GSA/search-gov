require 'spec/spec_helper'

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
    before do
      @monthly_popular_query = MonthlyPopularQuery.create(@valid_attributes)
    end
      
    it { should validate_presence_of :year }
    it { should validate_presence_of :month }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
  
    it "should default the to not grouped" do
      MonthlyPopularQuery.new.is_grouped.should be_false
    end
  end
end
