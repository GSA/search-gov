require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::HomeController do

  it "should assign popular terms for yesterday, trailing week, and trailing month" do
    DailyQueryStat.should_receive(:popular_terms_over_days).with(1).and_return("yday")
    DailyQueryStat.should_receive(:popular_terms_over_days).with(7).and_return("week")
    DailyQueryStat.should_receive(:popular_terms_over_days).with(30).and_return("month")
    get :index
    assigns[:yesterday_popular_terms].should == "yday"
    assigns[:trailing_week_popular_terms].should == "week"
    assigns[:trailing_month_popular_terms].should == "month"
  end

  it "should assign biggest movers for daily, weekly, and monthly windows" do
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(1).and_return("ydaybm")
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(7).and_return("weekbm")
    DailyQueryStat.should_receive(:biggest_mover_popularity_over_window).with(30).and_return("monthbm")
    get :index
    assigns[:yesterday_biggest_movers].should == "ydaybm"
    assigns[:weekly_biggest_movers].should == "weekbm"
    assigns[:monthly_biggest_movers].should == "monthbm"
  end

end
