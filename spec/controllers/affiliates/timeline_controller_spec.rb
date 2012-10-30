require 'spec_helper'

describe Affiliates::TimelineController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #show" do
    it "should require affiliate login for edit_site_information" do
      get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
      response.should redirect_to(login_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for show" do
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being shown" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :show, :id => affiliates(:another_affiliate).id, :query => 'jobs'
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as the affiliate manager" do
      before do
        UserSession.create(users(:affiliate_manager))
        @affiliate = affiliates(:power_affiliate)
        DailyQueryStat.create!(:day => Date.current - 2, :query => "jobs", :times => 9, :affiliate => @affiliate.name)
        DailyQueryStat.create!(:day => Date.current - 1, :query => "jobs", :times => 900, :affiliate => @affiliate.name)
        DailyQueryStat.create!(:day => Date.current - 2, :query => "benefits", :times => 9, :affiliate => @affiliate.name)
        DailyQueryStat.create!(:day => Date.current - 1, :query => "benefits", :times => 900, :affiliate => @affiliate.name)
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
      end

      it "should assign @title" do
        assigns[:title].should_not be_blank
      end

      it "should assign @affiliate" do
        assigns[:affiliate].should == @affiliate
      end

      it "should assign @query" do
        assigns[:query].should == 'jobs'
      end

      it "should assign @chart with a data column" do
        assigns[:chart].should_not be_nil
        assigns[:chart].data_table.cols[0].should == {:type=>"date", :label=>"Date"}
        assigns[:chart].data_table.cols[1].should == {:type=>"number", :label=>"jobs"}
      end

      context "when comparison query is passed in" do
        before do
          get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs', :comparison_query => 'benefits'
        end

        it "should assign @comparison_query" do
          assigns[:comparison_query].should == 'benefits'
        end

        it "should assign @chart with two data columns" do
          assigns[:chart].should_not be_nil
          assigns[:chart].data_table.cols[0].should == {:type=>"date", :label=>"Date"}
          assigns[:chart].data_table.cols[1].should == {:type=>"number", :label=>"jobs"}
          assigns[:chart].data_table.cols[2].should == {:type=>"number", :label=>"benefits"}
        end
      end

    end
  end
end
