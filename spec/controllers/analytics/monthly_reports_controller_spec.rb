require 'spec_helper'

describe Analytics::MonthlyReportsController do
  fixtures :users

  describe "#index" do
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
            
      it "should set the report date to the current month" do
        get :index
        report_date = assigns[:report_date]
        report_date.month.should == Date.today.month
        report_date.year.should == Date.today.year
      end
      
      it "should set the report date to the first day of the month of the parameters passed in" do
        get :index, :date => { :month => 3, :year => 2010 }
        report_date = assigns[:report_date]
        report_date.month.should == 3
        report_date.year.should == 2010
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
       
        it "should link to the reports on Amazon S3 using SSL" do
          %w{en es}.each do |locale|
            AWS::S3::S3Object.should_receive(:url_for).with("#{locale}_top_queries_#{Date.yesterday.strftime('%Y%m')}.csv", "usasearch-reports", :use_ssl => true).once.and_return ""
          end
          get :index
        end
      end
    end
  end
  
end
