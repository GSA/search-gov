require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
        Affiliate.should_receive(:find).and_return(@affiliate)

        @jobs_timeline = mock('jobs_timeline')
        Timeline.should_receive(:load_affiliate_daily_query_stats).with('jobs', @affiliate.name).and_return(@jobs_timeline)

        @last_jobs_timeline_day = Date.parse('2010-12-31')
        dates = [@last_jobs_timeline_day.advance(:days => -1), @last_jobs_timeline_day]
        @jobs_timeline.should_receive(:dates).and_return(dates)
      end

      it "should assign @title" do
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
        assigns[:title].should_not be_blank
      end

      it "should assign @affiliate" do
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
        assigns[:affiliate].should == @affiliate
      end

      it "should assign @query" do
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
        assigns[:query].should == 'jobs'
      end

      it "should assign @comparison_query" do
        Timeline.should_receive(:load_affiliate_daily_query_stats).with('benefits', @affiliate.name).and_return('benefits_result')
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs', :comparison_query => 'benefits'
        assigns[:comparison_query].should == 'benefits'
      end

      it "should load affiliate daily query stats timeline" do
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
      end

      it "should append results to @timelines" do
        Timeline.should_receive(:load_affiliate_daily_query_stats).with('benefits', @affiliate.name).and_return('benefits_result')
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs', :comparison_query => 'benefits'
        assigns[:timelines].should == [@jobs_timeline, 'benefits_result']
      end

      it "should assign @zoom_start_time to a month before the last date" do
        get :show, :id => affiliates(:power_affiliate).id, :query => 'jobs'
        assigns[:zoom_start_time].should == Date.parse('2010-11-30')
      end
    end
  end
end
