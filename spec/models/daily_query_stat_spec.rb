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

  describe '#most_popular_terms' do
    context "when the table is populated" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 9 )
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 2 )
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 1 )
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 4 )
      end

      it "should calculate popularity sums based on the target date and number of days parameter" do
        yday = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1)
        yday.first[0].should == "recent day most popular"
        yday.first[1].should == 4
        twodaysago = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 2)
        twodaysago.first[0].should == "older most popular"
        twodaysago.first[1].should == 10
      end

      it "should use the num_results parameter to determine result set size" do
        DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1,1).size.should == 1
      end
    end

    context "when the table has no data for the time period specified" do
      before do
        DailyQueryStat.delete_all
      end

      it "should return nil" do
        DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1).should be_nil
      end
    end
  end

  describe '#biggest_movers' do
    context "when the table is populated" do
      before do
        DailyQueryStat.delete_all
        day = 3.days.ago
        DailyQueryStat.create!(:day => day, :query => "most recent day least popular highest score", :times => 1 )
        DailyQueryStat.create!(:day => day, :query => "most recent day most popular lowest score", :times => 4 )
        QueryAcceleration.create!(:day => day, :query => "most recent day least popular highest score", :window_size => 1, :score => 2.0)
        QueryAcceleration.create!(:day => day, :query => "most recent day most popular lowest score", :window_size => 1, :score => 1.0)
      end

      it "should rank biggest movers for the most recent data available based on search popularity and the target date and number of days parameter" do
        movers = DailyQueryStat.biggest_movers(DailyQueryStat.most_recent_populated_date, 1)
        movers.first[:query].should == "most recent day most popular lowest score"
        movers.last[:query].should == "most recent day least popular highest score"
      end

      it "should use the num_results parameter to determine result set size" do
        DailyQueryStat.biggest_movers(DailyQueryStat.most_recent_populated_date, 1,1).size.should == 1
      end
    end

    context "when the table has no data for the time period specified" do
      before do
        DailyQueryStat.delete_all
      end

      it "should return nil" do
        DailyQueryStat.biggest_movers(DailyQueryStat.most_recent_populated_date, 1).should be_nil
      end
    end
  end

  describe "#most_recent_populated_date" do
    it "should return the most recent date entered into the table" do
      DailyQueryStat.should_receive(:maximum).with(:day)
      DailyQueryStat.most_recent_populated_date
    end
  end

end
