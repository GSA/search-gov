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
      @daily_usage_stat = DailyUsageStat.new(:day => @yesterday, :profile => 'English')
      response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"TAaTt56X0j6\",\"ID\":\"TAaTt56X0j6\",\"name\":\"Search English\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"3/2/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:04:34\",\"Median Visit Duration\":\"00:00:59\",\"Visit Duration Seconds\":\"3,410,681\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"14:00-14:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-09 23:39:59\",\"Last Analysis Date\":\"2010-03-09 19:19:48\"},\"measures\":{\"Page Views\":84124.0,\"Visits\":16358.0,\"Visits from Your Country: United States (US)\":88.45,\"International Visits\":11.55,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":84124.0,\"Page Views per Visit\":5.14,\"Average Visits per Day\":16358.0,\"Average Visits per Visitor\":1.05,\"Visitors\":15633.0,\"Visitors Who Visited Once\":15065.0,\"Visitors Who Visited More Than Once\":568.0,\"Visit Duration Seconds Count\":12412.0,\"Total Hits\":84124.0,\"Successful Hits\":84124.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":16358.0,\"Average Number of Hits per day on Weekdays\":84124.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      @daily_usage_stat.stub!(:get_profile_data).and_return response_body
    end
    
    it "should populate the proper data for each of the daily metrics" do
      @daily_usage_stat.populate_data
      @daily_usage_stat.total_queries.should be_nil   # can't calculate this yet
      @daily_usage_stat.total_page_views.should == 84124
      @daily_usage_stat.total_unique_visitors.should == 15633
      @daily_usage_stat.total_clicks.should be_nil    # can't calculate this yet
    end
    
    after do
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
