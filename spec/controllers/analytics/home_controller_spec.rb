require 'spec/spec_helper'

describe Analytics::HomeController do
  fixtures :users, :daily_query_stats, :affiliates

  describe "do GET on #index" do
    context "when not logged in" do
      it "should redirect to the login page" do
        get :index
        response.should redirect_to(login_path)
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

      it "should render the index page" do
        get :index
        response.should render_template('index')
      end
    end
  end

  describe "do GET on #queries" do
    context "when not logged in" do
      it "should redirect to the login page" do
        get :queries
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as a non-analyst user" do
      before do
        activate_authlogic
        UserSession.create(:email=> users("non_affiliate_admin").email, :password => "admin")
      end

      it "should redirect to the usasearch home page" do
        get :queries
        response.should redirect_to(home_page_url)
      end
    end

    context "when logged in as an analyst" do
      before do
        activate_authlogic
        UserSession.create(:email=> users("analyst").email, :password => "admin")
      end

      it "should assign @page_title" do
        get :queries
        assigns[:page_title].should_not be_blank
      end

      describe "dates being shown" do
        context "when no end date is selected by user" do
          it "should assign the most recent day" do
            get :queries
            assigns[:end_date].should == DailyQueryStat.most_recent_populated_date
            assigns[:start_date].should == DailyQueryStat.most_recent_populated_date
          end
        end

        context "when date is blank" do
          it "should assign the most recent day" do
            get :queries, :day => ''
            assigns[:end_date].should == DailyQueryStat.most_recent_populated_date
            assigns[:start_date].should == DailyQueryStat.most_recent_populated_date
          end
        end

        context "when user selects a start/end date" do
          it "should use those dates for the days being shown" do
            get :queries, :start_date => "July 21, 2009", :end_date => "July 22, 2009"
            assigns[:start_date].should == "July 21, 2009".to_date
            assigns[:end_date].should == "July 22, 2009".to_date
          end
        end
      end

      it "should set a value for the number of results to show per Most Popular section (i.e., 1 day, 7 day, 30 day)" do
        get :queries
        assigns[:num_results_dqs].should_not be_nil
      end

      context "when data for multiple affiliates is available" do
        before do
          DailyQueryStat.create!(:day => Date.yesterday, :query => "basic affiliate query", :times => 11, :locale => I18n.default_locale.to_s, :affiliate => affiliates(:basic_affiliate).name)
          DailyQueryStat.create!(:day => Date.yesterday, :query => "default query", :times => 11, :locale => I18n.default_locale.to_s, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        end

        it "should only get the data for the default affiliate" do
          get :queries
          assigns[:popular_terms].size.should == 1
          assigns[:popular_terms].first.query.should == "default query"
        end
      end

      context "when the number of results for the most popular queries is set by the user" do
        before do
          get :queries, :num_results_dqs=> "20"
        end
        it "should use the param as the number of results to show per section" do
          assigns[:num_results_dqs].should == 20
        end
      end

      describe "downloadable CVS reports" do
        render_views
        before do
          AWS::S3::Base.stub!(:establish_connection!).and_return true
          DailyQueryStat.stub!(:most_recent_populated_date).and_return Date.yesterday
          DailyQueryStat.stub!(:minimum).and_return Date.yesterday
          DailyQueryStat.stub!(:maximum).and_return Date.yesterday
        end

        it "should establish an AWS connection" do
          AWS::S3::Base.should_receive(:establish_connection!).once
          get :queries
        end

        it "should link to the reports on Amazon S3 using SSL if the file exists on S3" do
          %w{en es}.each do |locale|
            filename = "analytics/reports/#{locale}/#{locale}_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
            AWS::S3::S3Object.should_receive(:exists?).with(filename, AWS_BUCKET_NAME).and_return true
            AWS::S3::S3Object.should_receive(:url_for).with(filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
          end
          get :queries
          response.body.should contain(/Download CSV of top queries for/)
          response.body.should contain(/English, Spanish/)
        end

        it "should not link to the English report on S3 if it doesn't exist" do
          english_filename = "analytics/reports/en/en_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(english_filename, AWS_BUCKET_NAME).and_return false
          AWS::S3::S3Object.should_not_receive(:url_for).with(english_filename, AWS_BUCKET_NAME, :use_ssl => true)
          spanish_filename = "analytics/reports/es/es_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(spanish_filename, AWS_BUCKET_NAME).and_return true
          AWS::S3::S3Object.should_receive(:url_for).with(spanish_filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
          get :queries
          response.body.should contain(/Download CSV of top queries for/)
          response.body.should_not contain(/English/)
          response.body.should contain(/Spanish/)
          response.body.should_not contain(/, Spanish/)
        end

        it "should not link to the Spanish report on S3 if it doesn't exist" do
          english_filename = "analytics/reports/en/en_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(english_filename, AWS_BUCKET_NAME).and_return true
          AWS::S3::S3Object.should_receive(:url_for).with(english_filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
          spanish_filename = "analytics/reports/es/es_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(spanish_filename, AWS_BUCKET_NAME).and_return false
          AWS::S3::S3Object.should_not_receive(:url_for).with(spanish_filename, AWS_BUCKET_NAME, :use_ssl => true)
          get :queries
          response.body.should contain(/Download CSV of top queries for/)
          response.body.should contain(/English/)
          response.body.should_not contain(/Spanish/)
          response.body.should_not contain(/English,/)
        end

        it "should not link to the reports if neither exist" do
          %w{en es}.each do |locale|
            filename = "analytics/reports/#{locale}/#{locale}_top_queries_#{DailyQueryStat.most_recent_populated_date.strftime('%Y%m%d')}.csv"
            AWS::S3::S3Object.should_receive(:exists?).with(filename, AWS_BUCKET_NAME).and_return false
            AWS::S3::S3Object.should_not_receive(:url_for).with(filename, AWS_BUCKET_NAME, :use_ssl => true)
          end
          get :queries
          response.body.should_not contain(/Download CSV of top queries for/)
          response.body.should_not contain(/English/)
          response.body.should_not contain(/Spanish/)
        end
      end
    end
  end
end
