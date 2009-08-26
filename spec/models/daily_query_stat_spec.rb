require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyQueryStat do
  fixtures :daily_query_stats
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :times => 314
    }
  end
  describe 'validations on create' do
    should_validate_presence_of(:day, :query, :times)
    should_validate_uniqueness_of :query, :scope => :day

    it "should create a new instance given valid attributes" do
      DailyQueryStat.create!(@valid_attributes)
    end
  end

  describe '#popular_terms_over_days' do
    context "when the table is populated" do
      before do
        DailyQueryStat.create!(:day => 2.days.ago.to_date, :query => "two days ago most popular", :times => 9 )
        DailyQueryStat.create!(:day => 2.days.ago.to_date, :query => "yday most popular", :times => 2 )
        DailyQueryStat.create!(:day => 1.days.ago.to_date, :query => "two days ago most popular", :times => 1 )
        DailyQueryStat.create!(:day => 1.days.ago.to_date, :query => "yday most popular", :times => 4 )
      end

      it "should calculate popularity sums based on the number of days parameter" do
        yday = DailyQueryStat.popular_terms_over_days(1)
        yday.first[0].should == "yday most popular"
        yday.first[1].should == 4
        twodaysago = DailyQueryStat.popular_terms_over_days(2)
        twodaysago.first[0].should == "two days ago most popular"
        twodaysago.first[1].should == 10
      end
    end

    context "when the table has no data for the time period specified" do
      before do
        DailyQueryStat.delete_all
      end

      it "should return nil" do
        DailyQueryStat.popular_terms_over_days(1).should be_nil
      end
    end
  end

end
