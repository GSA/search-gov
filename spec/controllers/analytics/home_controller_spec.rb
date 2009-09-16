require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::HomeController do

  it "should assign popular terms for the most recent available day, its trailing week, and its trailing month" do
    DailyQueryStat.should_receive(:popular_terms_over_days).with(1, 10).and_return("yday")
    DailyQueryStat.should_receive(:popular_terms_over_days).with(7, 10).and_return("week")
    DailyQueryStat.should_receive(:popular_terms_over_days).with(30, 10).and_return("month")
    get :index
    assigns[:most_recent_day_popular_terms].should == "yday"
    assigns[:trailing_week_popular_terms].should == "week"
    assigns[:trailing_month_popular_terms].should == "month"
  end

  it "should assign biggest movers for daily, weekly, and monthly windows" do
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(1, 10).and_return("ydaybm")
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(7, 10).and_return("weekbm")
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(30, 10).and_return("monthbm")
    get :index
    assigns[:most_recent_day_biggest_movers].should == "ydaybm"
    assigns[:weekly_biggest_movers].should == "weekbm"
    assigns[:monthly_biggest_movers].should == "monthbm"
  end

  context "when analytics data available" do
    fixtures :daily_query_stats
    it "should assign the most recent day" do
      get :index
      assigns[:most_recent_day].should_not be_nil
    end
  end

  it "should set a value for the number of results to show per section" do
    get :index
    assigns[:num_results1].should_not be_nil
    assigns[:num_results7].should_not be_nil
    assigns[:num_results30].should_not be_nil
  end

  context "the number of results for the daily window is set by the user" do
    before do
      get :index, :num_results1=> "20"
    end
    it "should use the param as the number of results to show per section" do
      assigns[:num_results1].should == 20
    end
  end

  context "the number of results for the weekly window is set by the user" do
    before do
      get :index, :num_results7=> "20"
    end
    it "should use the param as the number of results to show per section" do
      assigns[:num_results7].should == 20
    end
  end

  context "the number of results for the monthly window is set by the user" do
    before do
      get :index, :num_results30=> "20"
    end
    it "should use the param as the number of results to show per section" do
      assigns[:num_results30].should == 20
    end
  end

end
