require "#{File.dirname(__FILE__)}/../spec_helper"

describe MonthlyClickTotal do
  before do
    @valid_attributes = {
      :year => 2011,
      :month => 3,
      :source => "BREL",
      :total => 100
    }
  end
  
  describe "creating a new instance" do
    before do
      @monthly_click_total = MonthlyClickTotal.create(@valid_attributes)
    end
      
    should_validate_presence_of :year, :month, :source, :total
    should_validate_uniqueness_of :source, :scope => [:year, :month]
    should_validate_numericality_of :total, :greater_than_or_equal_to => 10
  end
end
