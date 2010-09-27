require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "Daily Usage Stats rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/daily_usage_stats"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:compile_usage_stats_for_yesterday" do
    before do
      @task_name = "usasearch:compile_usage_stats_for_yesterday"
      english_response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"TAaTt56X0j6\",\"ID\":\"TAaTt56X0j6\",\"name\":\"Search English\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"03/02/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:04:34\",\"Median Visit Duration\":\"00:00:59\",\"Visit Duration Seconds\":\"3,410,681\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"14:00-14:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-09 23:39:59\",\"Last Analysis Date\":\"2010-03-09 19:19:48\"},\"measures\":{\"Page Views\":84124.0,\"Visits\":16358.0,\"Visits from Your Country: United States (US)\":88.45,\"International Visits\":11.55,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":84124.0,\"Page Views per Visit\":5.14,\"Average Visits per Day\":16358.0,\"Average Visits per Visitor\":1.05,\"Visitors\":15633.0,\"Visitors Who Visited Once\":15065.0,\"Visitors Who Visited More Than Once\":568.0,\"Visit Duration Seconds Count\":12412.0,\"Total Hits\":84124.0,\"Successful Hits\":84124.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":16358.0,\"Average Number of Hits per day on Weekdays\":84124.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      spanish_response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"I2JrcxgX0j6\",\"ID\":\"I2JrcxgX0j6\",\"name\":\"Search Spanish\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"03/02/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:04:24\",\"Median Visit Duration\":\"00:01:11\",\"Visit Duration Seconds\":\"75,819\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"20:00-20:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-10 08:39:59\",\"Last Analysis Date\":\"2010-03-10 07:21:59\"},\"measures\":{\"Page Views\":1970.0,\"Visits\":391.0,\"Visits from Your Country: United States (US)\":56.27,\"International Visits\":43.73,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":1970.0,\"Page Views per Visit\":5.04,\"Average Visits per Day\":391.0,\"Average Visits per Visitor\":1.02,\"Visitors\":383.0,\"Visitors Who Visited Once\":375.0,\"Visitors Who Visited More Than Once\":8.0,\"Visit Duration Seconds Count\":287.0,\"Total Hits\":1970.0,\"Successful Hits\":1970.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":391.0,\"Average Number of Hits per day on Weekdays\":1970.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      affiliates_response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"ivO5EkIX0j6\",\"ID\":\"ivO5EkIX0j6\",\"name\":\"Search Affiliates\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"03/02/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:03:16\",\"Median Visit Duration\":\"00:00:37\",\"Visit Duration Seconds\":\"9,458,667\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"14:00-14:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-10 08:39:59\",\"Last Analysis Date\":\"2010-03-10 07:34:43\"},\"measures\":{\"Page Views\":260563.0,\"Visits\":65413.0,\"Visits from Your Country: United States (US)\":89.38,\"International Visits\":10.62,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":260563.0,\"Page Views per Visit\":3.98,\"Average Visits per Day\":65413.0,\"Average Visits per Visitor\":1.04,\"Visitors\":63057.0,\"Visitors Who Visited Once\":61098.0,\"Visitors Who Visited More Than Once\":1959.0,\"Visit Duration Seconds Count\":48171.0,\"Total Hits\":260563.0,\"Successful Hits\":260563.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":65413.0,\"Average Number of Hits per day on Weekdays\":260563.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      @report_date = Date.parse('2010-03-02')
      @english_daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'English')
      @spanish_daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'Spanish')
      @affiliates_daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'Affiliates')
      @english_daily_usage_stat.stub!(:get_profile_data).and_return english_response_body
      @spanish_daily_usage_stat.stub!(:get_profile_data).and_return spanish_response_body
      @affiliates_daily_usage_stat.stub!(:get_profile_data).and_return affiliates_response_body
      DailyUsageStat.stub!(:new).and_return { :profile == 'English' ? @english_daily_usage_stat : :profile == 'Spanish' ? @spanish_daily_usage_stat : @affiliates_daily_usage_stat }
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should delete existing data for the past day, if it exists" do
      DailyUsageStat.should_receive(:delete_all).with(["day = ?", Date.yesterday]).exactly(1).times
      @rake[@task_name].invoke
    end

    it "should populate data for all of the current profiles and affiliates" do
      DailyUsageStat.should_receive(:new).exactly(DailyUsageStat::PROFILES.size + Affiliate.all.size).times
      @rake[@task_name].invoke
    end
    
    context "when an error occurs" do
      before do
        @daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'English')
        @daily_usage_stat.stub!(:save).and_return false
        DailyUsageStat.stub!(:new).and_return @daily_usage_stat
      end

      it "should log an error" do
        RAILS_DEFAULT_LOGGER.should_receive(:error).exactly(DailyUsageStat::PROFILE_NAMES.size + Affiliate.all.size).times
        @rake[@task_name].invoke
      end
    end

  end

  describe "usasearch:update_usage_stats" do
    before do
      @task_name = "usasearch:update_usage_stats"
      english_response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"TAaTt56X0j6\",\"ID\":\"TAaTt56X0j6\",\"name\":\"Search English\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"03/02/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:04:34\",\"Median Visit Duration\":\"00:00:59\",\"Visit Duration Seconds\":\"3,410,681\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"14:00-14:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-09 23:39:59\",\"Last Analysis Date\":\"2010-03-09 19:19:48\"},\"measures\":{\"Page Views\":84124.0,\"Visits\":16358.0,\"Visits from Your Country: United States (US)\":88.45,\"International Visits\":11.55,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":84124.0,\"Page Views per Visit\":5.14,\"Average Visits per Day\":16358.0,\"Average Visits per Visitor\":1.05,\"Visitors\":15633.0,\"Visitors Who Visited Once\":15065.0,\"Visitors Who Visited More Than Once\":568.0,\"Visit Duration Seconds Count\":12412.0,\"Total Hits\":84124.0,\"Successful Hits\":84124.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":16358.0,\"Average Number of Hits per day on Weekdays\":84124.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      spanish_response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"I2JrcxgX0j6\",\"ID\":\"I2JrcxgX0j6\",\"name\":\"Search Spanish\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"03/02/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:04:24\",\"Median Visit Duration\":\"00:01:11\",\"Visit Duration Seconds\":\"75,819\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"20:00-20:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-10 08:39:59\",\"Last Analysis Date\":\"2010-03-10 07:21:59\"},\"measures\":{\"Page Views\":1970.0,\"Visits\":391.0,\"Visits from Your Country: United States (US)\":56.27,\"International Visits\":43.73,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":1970.0,\"Page Views per Visit\":5.04,\"Average Visits per Day\":391.0,\"Average Visits per Visitor\":1.02,\"Visitors\":383.0,\"Visitors Who Visited Once\":375.0,\"Visitors Who Visited More Than Once\":8.0,\"Visit Duration Seconds Count\":287.0,\"Total Hits\":1970.0,\"Successful Hits\":1970.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":391.0,\"Average Number of Hits per day on Weekdays\":1970.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      affiliates_response_body = "{\"definition\":{\"accountID\":19421,\"profileID\":\"ivO5EkIX0j6\",\"ID\":\"ivO5EkIX0j6\",\"name\":\"Search Affiliates\",\"language\":null,\"type\":\"profilestats\",\"dimension\":{\"ID\":null,\"name\":\"Date\",\"type\":\"period\",\"Range\":{\"startperiod\":\"2010m03d02\",\"trendperiods\":1},\"Properties\":null,\"SubDimension\":null},\"measures\":null},\"data\":{\"03/02/2010\":{\"Attributes\":{\"Average Visit Duration\":\"00:03:16\",\"Median Visit Duration\":\"00:00:37\",\"Visit Duration Seconds\":\"9,458,667\",\"Most Active Date\":\"-\",\"Most Active Day of the Week\":\"-\",\"Most Active Hour of the Day\":\"14:00-14:59\",\"Least Active Date\":\"-\",\"Last Realtime Analysis Date\":\"2010-03-10 08:39:59\",\"Last Analysis Date\":\"2010-03-10 07:34:43\"},\"measures\":{\"Page Views\":260563.0,\"Visits\":65413.0,\"Visits from Your Country: United States (US)\":89.38,\"International Visits\":10.62,\"Visits of Unknown Origin\":0.0,\"Average Page Views per Day\":260563.0,\"Page Views per Visit\":3.98,\"Average Visits per Day\":65413.0,\"Average Visits per Visitor\":1.04,\"Visitors\":63057.0,\"Visitors Who Visited Once\":61098.0,\"Visitors Who Visited More Than Once\":1959.0,\"Visit Duration Seconds Count\":48171.0,\"Total Hits\":260563.0,\"Successful Hits\":260563.0,\"Successful Hits (as Percent)\":100.0,\"Failed Hits\":0.0,\"Failed Hits (as Percent)\":0.0,\"Cached Hits\":0.0,\"Cached Hits (as Percent)\":0.0,\"Number of Hits on Most Active Date\":null,\"Average Number of Visits per day on Weekdays\":65413.0,\"Average Number of Hits per day on Weekdays\":260563.0,\"Total Hits Weekend\":null,\"Average Number of Visits per Weekend\":0.0,\"Average Number of Hits per Weekend\":0.0},\"SubRows\":null}}}"
      @report_date = Date.parse('2010-03-02')
      @english_daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'English')
      @spanish_daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'Spanish')
      @affiliates_daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'Affiliates')
      @english_daily_usage_stat.stub!(:get_profile_data).and_return english_response_body
      @spanish_daily_usage_stat.stub!(:get_profile_data).and_return spanish_response_body
      @affiliates_daily_usage_stat.stub!(:get_profile_data).and_return affiliates_response_body
      DailyUsageStat.stub!(:new).and_return { :profile == 'English' ? @english_daily_usage_stat : :profile == 'Spanish' ? @spanish_daily_usage_stat : @affiliates_daily_usage_stat }
      @start_date = Date.parse('2010-03-01')
      @end_date = Date.parse('2010-03-09')
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should log an error if no parameters are specified" do
      RAILS_DEFAULT_LOGGER.should_receive(:error)
      @rake[@task_name].invoke
    end

    it "should log an error if only one parameter is specified" do
      RAILS_DEFAULT_LOGGER.should_receive(:error)
      @rake[@task_name].invoke('2010-03-01')
    end

    it "should delete all data from start to end date" do
      DailyUsageStat.should_receive(:delete_all).with(["day between ? and ?", @start_date, @end_date]).exactly(1).times
      @rake[@task_name].invoke('2010-03-01', '2010-03-09')
    end

    it "should populate usage stats once per day for each profile and each affiliate" do
      DailyUsageStat.should_receive(:new).exactly((DailyUsageStat::PROFILE_NAMES.size + Affiliate.all.size) * (@end_date - @start_date + 1)).times
      @rake[@task_name].invoke('2010-03-01', '2010-03-09')
    end

    context "when an error occurs" do
      before do
        @daily_usage_stat = DailyUsageStat.new(:day => @report_date, :profile => 'English')
        @daily_usage_stat.stub!(:save).and_return false
        DailyUsageStat.stub!(:new).and_return @daily_usage_stat
      end

      it "should log an error" do
        RAILS_DEFAULT_LOGGER.should_receive(:error).exactly((DailyUsageStat::PROFILE_NAMES.size + Affiliate.all.size) * (@end_date - @start_date + 1)).times
        @rake[@task_name].invoke('2010-03-01', '2010-03-09')
      end
    end

  end
  
  describe "#compute_daily_contextual_query_total" do
    before do
      @task_name = "usasearch:compute_daily_contextual_query_total"
      DailyContextualQueryTotal.delete_all
    end
    
    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end
    
    it "should use the date provided as a parameter" do
      @rake[@task_name].invoke('2010-09-01')
      DailyContextualQueryTotal.find_by_day(Date.parse('2010-09-01')).should_not be_nil
    end
    
    it "should default to yesterday if no day is provided as a parameter" do
      @rake[@task_name].invoke
      DailyContextualQueryTotal.find_by_day(Date.yesterday).should_not be_nil
    end
    
    context "when a record exists for the date being totaled" do
      before do
        DailyContextualQueryTotal.create(:day => Date.yesterday, :total => 100)
      end
      
      it "should delete the existing record and create a new one with the new total" do
        @rake[@task_name].invoke
        DailyContextualQueryTotal.find_by_day(Date.yesterday).total.should == 0
      end
    end
  end
end
