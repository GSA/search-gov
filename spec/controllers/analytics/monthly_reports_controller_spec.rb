require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::MonthlyReportsController do
  fixtures :users

  describe "#index" do
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

      it "should set the report date to the month based on yesterday's date" do
        get :index
        report_date = assigns[:report_date]
        report_date.month.should == Date.yesterday.month
        report_date.year.should == Date.yesterday.year
      end

      it "should set the report date to the first day of the month of the parameters passed in" do
        get :index, :date => { :month => 3, :year => 2010 }
        report_date = assigns[:report_date]
        report_date.month.should == 3
        report_date.year.should == 2010
      end

      context "when rendering the monthly reports page" do
        render_views
        before do
          AWS::S3::Base.stub!(:establish_connection!).and_return true
        end

        it "should establish an AWS connection" do
          AWS::S3::Base.should_receive(:establish_connection!).once
          get :index
        end

        it "should link to the reports on Amazon S3 using SSL if they exist" do
          %w{en es}.each do |locale|
            filename = "analytics/reports/#{locale}/#{locale}_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv"
            AWS::S3::S3Object.should_receive(:exists?).with(filename, AWS_BUCKET_NAME).and_return true
            AWS::S3::S3Object.should_receive(:url_for).with(filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
          end
          get :index
          response.body.should contain(/Download top queries for/)
          response.body.should contain(/\(English, Spanish\)/)
        end

        it "should link to the English report only if the English exists, but the Spanish does not" do
          english_filename = "analytics/reports/en/en_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(english_filename, AWS_BUCKET_NAME).and_return true
          AWS::S3::S3Object.should_not_receive(:url_for).with(english_filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
          spanish_filename = "analytics/reports/es/es_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(spanish_filename, AWS_BUCKET_NAME).and_return false
          AWS::S3::S3Object.should_not_receive(:url_for).with(spanish_filename, AWS_BUCKET_NAME, :use_ssl => true)
          get :index
          response.body.should contain(/Download top queries for/)
          response.body.should contain(/\(English\)/)
        end

        it "should link to the Spanish report only if the Spanish exists, but the English does not" do
          english_filename = "analytics/reports/en/en_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(english_filename, AWS_BUCKET_NAME).and_return false
          AWS::S3::S3Object.should_not_receive(:url_for).with(english_filename, AWS_BUCKET_NAME, :use_ssl => true)
          spanish_filename = "analytics/reports/es/es_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv"
          AWS::S3::S3Object.should_receive(:exists?).with(spanish_filename, AWS_BUCKET_NAME).and_return true
          AWS::S3::S3Object.should_receive(:url_for).with(spanish_filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
          get :index
          response.body.should contain(/Download top queries for/)
          response.body.should contain(/\(Spanish\)/)
        end

        it "should not link to the reports if both don't exist" do
          %w{en es}.each do |locale|
            filename = "analytics/reports/#{locale}/#{locale}_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv"
            AWS::S3::S3Object.should_receive(:exists?).with(filename, AWS_BUCKET_NAME).and_return false
            AWS::S3::S3Object.should_not_receive(:url_for).with(filename, AWS_BUCKET_NAME, :use_ssl => true)
          end
          get :index
          response.body.should_not contain(/Download top queries for/)
          response.body.should_not contain(/\(English, Spanish\)/)
        end

        context "when viewing most popular queries and query groups" do
          it "should set the number of results to 10 if no parameter is specified" do
            get :index
            assigns[:num_results_mpq].should == 10
          end

          it "should display the top most popular queries based on parameter specified" do
            get :index, :num_results_mpq => "50"
            assigns[:num_results_mpq].should == 50
          end

          it "should set the number of results for query groups to 10 if no parameter is specified" do
            get :index
            assigns[:num_results_mpqg].should == 10
          end

          it "should set the number of results for query groups according to the parameter that is passed" do
            get :index, :num_results_mpqg => "50"
            assigns[:num_results_mpqg].should == 50
          end
        end
      end
    end
  end
end
