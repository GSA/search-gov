require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::HomeController do
  fixtures :users, :daily_query_stats

  context "when not logged in" do
    it "should redirect to the login page" do
      get :index
      response.should redirect_to(new_user_session_path)
    end
  end

  context "when logged in as a non-analyst user" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("non_affiliate_admin").email, :password => "admin")
    end

    it "should redirect to the usasearch home page" do
      get :index
      response.should redirect_to(home_page_url)
    end
  end

  context "when logged in as an analyst" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("analyst").email, :password => "admin")
    end

    it "should assign popular terms for the target day, its trailing week, and its trailing month" do
      yday = Date.yesterday.to_date
      DailyQueryStat.should_receive(:most_popular_terms).with(yday, 1, 10).and_return("ydaymp")
      DailyQueryStat.should_receive(:most_popular_terms).with(yday, 7, 10).and_return("weekmp")
      DailyQueryStat.should_receive(:most_popular_terms).with(yday, 30, 10).and_return("monthmp")
      get :index, :day => yday
      assigns[:most_recent_day_popular_terms].should == "ydaymp"
      assigns[:trailing_week_popular_terms].should == "weekmp"
      assigns[:trailing_month_popular_terms].should == "monthmp"
    end

    it "should assign biggest movers on the target day for daily, weekly, and monthly windows" do
      yday = Date.yesterday.to_date
      MovingQuery.should_receive(:biggest_movers).with(yday, 1, 10).and_return("ydaybm")
      MovingQuery.should_receive(:biggest_movers).with(yday, 7, 10).and_return("weekbm")
      MovingQuery.should_receive(:biggest_movers).with(yday, 30, 10).and_return("monthbm")
      get :index, :day => yday
      assigns[:most_recent_day_biggest_movers].should == "ydaybm"
      assigns[:weekly_biggest_movers].should == "weekbm"
      assigns[:monthly_biggest_movers].should == "monthbm"
    end

    describe "day_being_shown" do
      context "when no date is selected by user" do
        it "should assign the most recent day" do
          get :index
          assigns[:day_being_shown].should == DailyQueryStat.most_recent_populated_date
        end
      end

      context "when user selects a date" do
        it "should use that date for the day being shown" do
          get :index, :day => "July 21, 2009"
          assigns[:day_being_shown].should == "July 21, 2009".to_date
        end
      end
    end

    it "should set a value for the number of results to show per section" do
      get :index
      assigns[:num_results_qas].should_not be_nil
      assigns[:num_results_dqs].should_not be_nil
    end

    context "when the number of results for the most popular queries is set by the user" do
      before do
        get :index, :num_results_dqs=> "20"
      end
      it "should use the param as the number of results to show per section" do
        assigns[:num_results_dqs].should == 20
      end
    end

    context "when the number of results for the accelerating queries is set by the user" do
      before do
        get :index, :num_results_qas=> "20"
      end
      it "should use the param as the number of results to show per section" do
        assigns[:num_results_qas].should == 20
      end
    end

    context "when rendering the monthly reports page" do
      integrate_views
      before do
        AWS::S3::Base.stub!(:establish_connection!).and_return true
      end

      it "should establish an AWS connection" do
        AWS::S3::Base.should_receive(:establish_connection!).once
        get :index
      end

      it "should link to the reports on Amazon S3 using SSL if the file exists on S3" do
        %w{en es}.each do |locale|
          filename = "#{locale}_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(filename, REPORTS_AWS_BUCKET_NAME).and_return true
          AWS::S3::S3Object.should_receive(:url_for).with(filename, REPORTS_AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
        end
        get :index
        response.body.should contain(/Download CSV of top 1000 queries for/)
        response.body.should contain(/English, Spanish/)
      end

      it "should not link to the English report on S3 if it doesn't exist" do
        english_filename = "en_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
        AWS::S3::S3Object.should_receive(:exists?).with(english_filename, REPORTS_AWS_BUCKET_NAME).and_return false
        AWS::S3::S3Object.should_not_receive(:url_for).with(english_filename, REPORTS_AWS_BUCKET_NAME, :use_ssl => true)
        spanish_filename = "es_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
        AWS::S3::S3Object.should_receive(:exists?).with(spanish_filename, REPORTS_AWS_BUCKET_NAME).and_return true
        AWS::S3::S3Object.should_receive(:url_for).with(spanish_filename, REPORTS_AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
        get :index
        response.body.should contain(/Download CSV of top 1000 queries for/)
        response.body.should_not contain(/English/)
        response.body.should contain(/Spanish/)
        response.body.should_not contain(/, Spanish/)
      end

      it "should not link to the Spanish report on S3 if it doesn't exist" do
        english_filename = "en_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
        AWS::S3::S3Object.should_receive(:exists?).with(english_filename, REPORTS_AWS_BUCKET_NAME).and_return true
        AWS::S3::S3Object.should_receive(:url_for).with(english_filename, REPORTS_AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
        spanish_filename = "es_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
        AWS::S3::S3Object.should_receive(:exists?).with(spanish_filename, REPORTS_AWS_BUCKET_NAME).and_return false
        AWS::S3::S3Object.should_not_receive(:url_for).with(spanish_filename, REPORTS_AWS_BUCKET_NAME, :use_ssl => true)
        get :index
        response.body.should contain(/Download CSV of top 1000 queries for/)
        response.body.should contain(/English/)
        response.body.should_not contain(/Spanish/)
        response.body.should_not contain(/English,/)
      end

      it "should not link to the reports if neither exist" do
        %w{en es}.each do |locale|
          filename = "#{locale}_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(filename, REPORTS_AWS_BUCKET_NAME).and_return false
          AWS::S3::S3Object.should_not_receive(:url_for).with(filename, REPORTS_AWS_BUCKET_NAME, :use_ssl => true)
        end
        get :index
        response.body.should_not contain(/Download CSV of top 1000 queries for/)
        response.body.should_not contain(/English/)
        response.body.should_not contain(/Spanish/)
      end
    end
  end
end
