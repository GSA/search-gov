require 'spec/spec_helper'

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
    end

    it "should sum up all the DailyUsageStat values for the given month" do
      DailyUsageStat.should_receive(:total_monthly_queries).with(@year, @month, @affiliate.name).exactly(1).times
      DailyUsageStat.monthly_totals(@year, @month, @affiliate.name)
    end
  end
end
