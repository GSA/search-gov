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
    end
  end
  
  describe "#top_queries" do
    context "when not logged in" do
      it "should redirect to the login page" do
        get :top_queries
        response.should redirect_to(new_user_session_path)
      end
    end

    context "when logged in as a non-analyst user" do
      before do
        activate_authlogic
        UserSession.create(:email=> users("non_affiliate_admin").email, :password => "admin")
      end

      it "should redirect to the usasearch home page" do
        get :top_queries
        response.should redirect_to(home_page_url)
      end
    end
        
    context "when logged in as an analyst" do
      before do
        activate_authlogic
        UserSession.create(:email=> users("analyst").email, :password => "admin")
      end
            
      it "should set the report date to the current month" do
        get :top_queries
        report_date = assigns[:report_date]
        report_date.month.should == Date.today.month
        report_date.year.should == Date.today.year
      end
      
      it "should set the report date to the first day of the month of the parameters passed in" do
        get :top_queries, :date => { :month => 3, :year => 2010 }
        report_date = assigns[:report_date]
        report_date.month.should == 3
        report_date.year.should == 2010
      end
      
      it "should set the locale to 'en' if not specified" do
        get :top_queries
        assigns[:site_locale].should == 'en'
      end
      
      it "should set the locale according to the site_locale parameter" do
        get :top_queries, :site_locale => 'es'
        assigns[:site_locale].should == 'es'
      end
      
      it "should set the filename according to the year and month" do
        get :top_queries, :date => { :month => 3, :year => 2010 }
        filename = assigns[:filename]
        filename.should == 'top_queries_201003.csv'
      end
      
      it "should order the top queries by total descending" do
        DailyQueryStat.create(:day => Date.today, :query => 'apples', :times => 10)
        DailyQueryStat.create(:day => Date.today, :query => 'banana', :times => 8)
        DailyQueryStat.create(:day => Date.today, :query => 'pears', :times => 8)
        DailyQueryStat.create(:day => Date.today, :query => 'oranges', :times => 5)
        get :top_queries
        top_queries = assigns[:top_queries]
        top_queries.each_with_index do |top_query, index|
          top_query.total.to_i.should <= top_queries[index - 1].total.to_i unless index == 0
        end
      end
    end
  end
end
