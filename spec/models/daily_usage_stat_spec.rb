require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyUsageStat do
  before(:each) do
    @valid_attributes = {
      :day => Date.today,
      :profile => "value for profile",
      :total_queries => 1,
      :total_page_views => 1,
      :total_unique_visitors => 1,
      :total_clicks => 1
    }
  end

  it "should create a new instance given valid attributes" do
    DailyUsageStat.create!(@valid_attributes)
  end
  
  context "When populating data for yesterday" do
    before do
      @yesterday = Date.parse('20100302')
      #DailyQueryStat.delete_all
      #DailyQueryStat.create!(:day => @yesterday, :query => 'barack obama', :times => 100)
      #DailyQueryStat.create!(:day => @yesterday, :query => 'health care', :times => 200)
      @daily_usage_stat = DailyUsageStat.new(:day => @yesterday, :profile => 'English')
    end
    
    it "should populate the proper data for each of the daily metrics" do
      @daily_usage_stat.populate_data
      @daily_usage_stat.total_queries.should be_nil   # can't calculate this yet
      @daily_usage_stat.total_page_views.should == 84124
      @daily_usage_stat.total_unique_visitors.should == 15633
      @daily_usage_stat.total_clicks.should be_nil    # can't calculate this yet
    end
    
    after do
      #DailyQueryStat.delete_all
      DailyUsageStat.delete_all
    end
  end
  
  context "When compiling data for a given month" do
    before do
      @year = 2010
      @month = 03
    end
    
    it "should sum up all the DailyUsageStat values for the given month" do
      DailyUsageStat::Profile_Names.each do |profile_name|
        DailyUsageStat.should_receive(:total_monthly_queries).with(@year, @month, profile_name).exactly(1).times
        DailyUsageStat.should_receive(:total_monthly_page_views).with(@year, @month, profile_name).exactly(1).times
        DailyUsageStat.should_receive(:total_monthly_unique_visitors).with(@year, @month, profile_name).exactly(1).times
        DailyUsageStat.should_receive(:total_monthly_clicks).with(@year, @month, profile_name).exactly(1).times
      end
      DailyUsageStat.monthly_totals(@year, @month)
    end
  end
end
