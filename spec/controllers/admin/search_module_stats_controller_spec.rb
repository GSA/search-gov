require 'spec/spec_helper'

describe Admin::SearchModuleStatsController do
  fixtures :users, :search_modules, :daily_search_module_stats

  describe "#index" do

    context "when logged in as an analyst" do
      before do
        activate_authlogic
        UserSession.create(users(:affiliate_admin))
      end

      it "should assign @page_title" do
        get :index
        assigns[:page_title].should_not be_blank
      end

      describe "start and end dates" do
        context "when no dates are selected by user" do
          it "should assign the end date to be the most recent date available" do
            get :index
            assigns[:end_date].should == DailySearchModuleStat.most_recent_populated_date
          end
          it "should assign the start date to be the 1st day of the month of the most recent date available" do
            get :index
            assigns[:start_date].should == DailySearchModuleStat.most_recent_populated_date.beginning_of_month
          end
        end

        context "when end date is blank" do
          it "should assign the end date to be the most recent date available" do
            get :index, :end_date => ''
            assigns[:end_date].should == DailySearchModuleStat.most_recent_populated_date
          end
        end

        context "when start date is blank" do
          it "should assign the start date to be the 1st day of the month of the most recent date available" do
            get :index, :start_date => ''
            assigns[:start_date].should == DailySearchModuleStat.most_recent_populated_date.beginning_of_month
          end
        end

        context "when user selects start and end dates" do
          it "should use those dates for the days being shown" do
            get :index, :start_date => "July 21, 2011", :end_date => "July 29, 2011"
            assigns[:start_date].should == "July 21, 2011".to_date
            assigns[:end_date].should == "July 29, 2011".to_date
          end
        end
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

      describe "affiliate picklist" do
        it "should contain arrays of all affiliates ordered by name, with the fake usasearch.gov affiliate at the top" do
          get :index
          assigns[:affiliate_picklist].size.should == Affiliate.count
          assigns[:affiliate_picklist].first.should == ["affiliate.gov","affiliate.gov"]
          assigns[:affiliate_picklist].last.should == ["usagov","usagov"]
        end
      end

      describe "vertical" do
        context "when no vertical is specified by user" do
          it "should show data from all verticals" do
            get :index
            assigns[:vertical_pick].should be_nil
          end
        end

        context "when vertical param is blank" do
          it "should show data from all verticals" do
            get :index, :vertical_pick => ''
            assigns[:vertical_pick].should be_nil
          end
        end

        context "when user selects a vertical" do
          it "should use that vertical for the vertical being shown in the pick list" do
            get :index, :vertical_pick => "web"
            assigns[:vertical_pick].should == "web"
          end
        end
      end

      it "should assign @search_module_stats using the params given" do
        start_date = "July 21, 2011"
        end_date = "July 29, 2011"
        affiliate = "usasearch.gov"
        locale = "en"
        vertical = "web"
        DailySearchModuleStat.should_receive(:module_stats_for_daterange).with(start_date.to_date..end_date.to_date, affiliate, vertical).and_return "foo"
        get :index, :start_date => start_date, :end_date => end_date, :affiliate_pick => affiliate, :vertical_pick => vertical
        assigns[:search_module_stats].should == "foo"
      end
    end
  end
end
