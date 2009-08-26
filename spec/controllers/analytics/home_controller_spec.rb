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

end
