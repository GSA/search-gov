require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::HomeController do

  it "should assign popular terms for the most recent available day, its trailing week, and its trailing month" do
    DailyQueryStat.should_receive(:popular_terms_over_days).with(1).and_return("yday")
    DailyQueryStat.should_receive(:popular_terms_over_days).with(7).and_return("week")
    DailyQueryStat.should_receive(:popular_terms_over_days).with(30).and_return("month")
    get :index
    assigns[:most_recent_day_popular_terms].should == "yday"
    assigns[:trailing_week_popular_terms].should == "week"
    assigns[:trailing_month_popular_terms].should == "month"
  end

  it "should assign biggest movers for daily, weekly, and monthly windows" do
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(1).and_return("ydaybm")
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(7).and_return("weekbm")
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(30).and_return("monthbm")
    get :index
    assigns[:most_recent_day_biggest_movers].should == "ydaybm"
    assigns[:weekly_biggest_movers].should == "weekbm"
    assigns[:monthly_biggest_movers].should == "monthbm"
  end

  it "should assign the most recent day" do
    get :index
    assigns[:most_recent_day].should_not be_nil
  end

end
