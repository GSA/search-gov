require 'spec/spec_helper'

describe DailyContextualQueryTotal do
  fixtures :daily_contextual_query_totals
  
  before do
    @valid_attributes = {
      :day => Date.current,
      :total => 100
    }
  end

  it { should validate_numericality_of :total }
  it { should validate_uniqueness_of :day }

  it "should create a new instance given valid attributes" do
    DailyContextualQueryTotal.create!(@valid_attributes)
  end

  describe "#total_for" do
    before do
      DailyContextualQueryTotal.create(:day => Date.yesterday, :total => 100)
    end

    it "should find the total for the specified date, ignoring any contextual links or bots" do
      daily_total = DailyContextualQueryTotal.total_for(Date.yesterday)
      daily_total.should == 100
    end

    it "should return 0 if there's no record for that date" do
      daily_total = DailyContextualQueryTotal.total_for(Date.current - 2.days)
      daily_total.should == 0
    end
  end
end
