require 'spec/spec_helper'

describe Admin::MonthlyReportsController do
  fixtures :users, :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  describe "#index" do

    context "when logged in as a user without admin priveleges" do
      before do
        activate_authlogic
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to the home page" do
        get :index
        response.should redirect_to home_page_url
      end
    end

    context "when logged in as an admin" do
      before do
        activate_authlogic
        UserSession.create(users(:affiliate_admin))
      end

      it "should assign @page_title" do
        get :index
        assigns[:page_title].should_not be_blank
      end

      describe "affiliate" do
        context "when no affiliate is specified by user" do
          it "should show data from all affiliates" do
            get :index
            assigns[:affiliate_pick].should be_nil
          end
        end

        context "when affiliate param is blank" do
          it "should show data from all affiliates" do
            get :index, :affiliate_pick => ''
            assigns[:affiliate_pick].should be_nil
          end
        end

        context "when user selects a affiliate" do
          it "should use that affiliate for the affiliate being shown in the pick list" do
            get :index, :affiliate_pick => "noaa.gov"
            assigns[:affiliate_pick].should == "noaa.gov"
          end
        end
      end

      describe "affiliate_report_name" do
        context "when no affiliate is specified by user" do
          it "should show data from all affiliates" do
            get :index
            assigns[:affiliate_report_name].should == '_all_'
          end
        end

        context "when user selects a affiliate" do
          it "should use that affiliate for the affiliate being shown in the pick list" do
            get :index, :affiliate_pick => "noaa.gov"
            assigns[:affiliate_report_name].should == "noaa.gov"
          end
        end
      end

      describe "affiliate picklist" do
        it "should contain arrays of all affiliates ordered by name, with the fake usasearch.gov affiliate at the top" do
          get :index
          assigns[:affiliate_picklist].size.should == Affiliate.count
          assigns[:affiliate_picklist].first.should == %w{affiliate.gov affiliate.gov}
          assigns[:affiliate_picklist].last.should == %w{usagov usagov}
        end
      end

      describe "report date" do
        context "when nothing is selected" do
          it "should default to the month/year for yesterday" do
            get :index
            assigns[:report_date].should == Date.yesterday
          end
        end

        context "when user selects a month and year" do
          it "should set the date to the first of the month for the specified year/month" do
            get :index, :date => {:month => 1, :year => 2010}
            assigns[:report_date].should == Date.parse("1/1/2010")
          end
        end
      end

      describe "most recent date" do
        context "by default" do
          it "should default to nil" do
            get :index
            assigns[:most_recent_data].should be_nil
          end
        end

        context "when an affiliate is specified" do
          context "when the affiliate has no usage stats" do
            it "should return the current date" do
              get :index, :affiliate_pick => @affiliate.name
              assigns[:most_recent_date].should == Date.current
            end
          end

          context "when the affiliate has usage stats" do
            before do
              DailyUsageStat.create!(:affiliate => @affiliate.name, :day => Date.yesterday, :total_queries => 100)
              DailyUsageStat.create!(:affiliate => @affiliate.name, :day => Date.yesterday.yesterday, :total_queries => 100)
            end

            it "should return the date of the most recent usage stat" do
              get :index, :affiliate_pick => @affiliate.name
              assigns[:most_recent_date].should == Date.yesterday
            end
          end
        end
      end

      describe "monthly_totals" do
        before do
          date = Date.parse('4/13/2012')
          DailyUsageStat.create!(:affiliate => @affiliate.name, :day => date, :total_queries => 100)
          DailyUsageStat.create!(:affiliate => @affiliate.name, :day => date.yesterday, :total_queries => 100)
          DailyUsageStat.create!(:affiliate => "someaffiliate", :day => date.yesterday, :total_queries => 100)
        end

        context "when no affiliate is present" do
          it "should return an aggregate of all affiliates for that date range" do
            get :index, :date => {:year => "2012", :month => "4"}
            assigns[:monthly_totals].should == 300
          end
        end

        context "when an affiliate is present" do
          it "should return the affiliate's monthly total" do
            get :index, :affiliate_pick => @affiliate.name, :date => {:year => "2012", :month => "4"}
            assigns[:monthly_totals].should == 200
          end
        end
      end

      describe "total clicks" do
        before do
          date = Date.parse('4/13/2012')
          DailySearchModuleStat.create!(:day => date, :locale => 'en', :affiliate_name => @affiliate.name, :vertical => 'TEST', :module_tag => 'TEST', :clicks => 100, :impressions => 100)
          DailySearchModuleStat.create!(:day => date.yesterday, :locale => 'en', :affiliate_name => @affiliate.name, :vertical => 'TEST', :module_tag => 'TEST', :clicks => 100, :impressions => 100)
          DailySearchModuleStat.create!(:day => date, :locale => 'en', :affiliate_name => "someaffiliate", :vertical => 'TEST', :module_tag => 'TEST', :clicks => 100, :impressions => 100)
        end

        context "when no affiliate is present" do
          it "should return a total of all the affiliates for that date range" do
            get :index, :date => {:year => "2012", :month => "4"}
            assigns[:total_clicks].should == 300
          end
        end

        context "when an affiliate is specified" do
          it "should return the affiliate's total clicks" do
            get :index, :affiliate_pick => @affiliate.name, :date => {:year => "2012", :month => "4"}
            assigns[:total_clicks].should == 200
          end
        end
      end
    end
  end
end
