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
      
    it { should validate_presence_of :year }
    it { should validate_presence_of :month }
    it { should validate_presence_of :source }
    it { should validate_presence_of :total }
    it { should validate_uniqueness_of(:source).scoped_to([:year, :month]) }
    it { should validate_numericality_of(:total) }
    it { should_not allow_value(9).for(:total) }
    it { should allow_value(10).for(:total) }
  end
end
