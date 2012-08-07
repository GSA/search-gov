require 'spec_helper'

describe DailyUsageStat do
  before(:each) do
    @valid_attributes = {
      :day => Date.current,
      :total_queries => 1
    }
  end

  describe "validations on create" do
    before do
      DailyUsageStat.create!(@valid_attributes)
    end

    it { should validate_presence_of :day }
    it { should validate_presence_of :affiliate }
    it { should validate_uniqueness_of(:day).scoped_to(:affiliate) }
  end

  context "When compiling data for a given month" do
    fixtures :affiliates
    before do
      @year = 2010
      @month = 03
      @affiliate = affiliates(:usagov_affiliate)
      DailyUsageStat.create(:day => Date.parse('2010-03-01'), :affiliate => @affiliate.name, :total_queries => 100)
      DailyUsageStat.create(:day => Date.parse('2010-03-02'), :affiliate => @affiliate.name, :total_queries => 100)
      DailyUsageStat.create(:day => Date.parse('2010-03-02'), :affiliate => "other_affiliate", :total_queries => 100)
    end

    it "should sum up all the DailyUsageStat values for the given month" do
      result = DailyUsageStat.monthly_totals(@year, @month, @affiliate.name)
      result.should == 200
    end

    context "when no affiliate is passed" do
      it "should sum up all the DailyUsageStat values for the given month for all affiliates" do
        result = DailyUsageStat.monthly_totals(@year, @month)
        result.should == 300
      end
    end
  end
end