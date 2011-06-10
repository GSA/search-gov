require 'spec/spec_helper'

describe Analytics::SearchModulesController do
  fixtures :users, :search_modules, :daily_search_module_stats

  describe "#index" do

    context "when logged in as an analyst" do
      before do
        activate_authlogic
        UserSession.create(:email=> users("analyst").email, :password => "admin")
      end

      it "should assign @page_title" do
        get :index
        assigns[:page_title].should_not be_blank
      end

      describe "@day_being_shown" do
        context "when no date is selected by user" do
          it "should assign the most recent day" do
            get :index
            assigns[:day_being_shown].should == DailySearchModuleStat.most_recent_populated_date
          end
        end

        context "when date is blank" do
          it "should assign the most recent day" do
            get :index, :day => ''
            assigns[:day_being_shown].should == DailySearchModuleStat.most_recent_populated_date
          end
        end

        context "when user selects a date" do
          it "should use that date for the day being shown" do
            get :index, :day => "July 21, 2011"
            assigns[:day_being_shown].should == "July 21, 2011".to_date
          end
        end
      end

      it "should assign @search_module_stats" do
        get :index
        assigns[:search_module_stats].should_not be_blank
      end
    end
  end
end
