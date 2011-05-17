require 'spec/spec_helper'

describe Analytics::QuerySearchesController do
  fixtures :users

  context "when logged in as an analyst" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("analyst").email, :password => "admin")
    end

    describe "#index" do

      context "when a search query term and start/end dates are passed in" do
        before do
          get :index, :query => "social security", :analytics_search_start_date => "August 11, 2010", :analytics_search_end_date => "August 21, 2010"
        end

        it "should set the search query term" do
          assigns[:search_query_term].should == "social security"
        end

        it "should assign the start date" do
          assigns[:start_date].should == Date.parse("August 11, 2010").to_date
        end

        it "should assign the end date" do
          assigns[:end_date].should == Date.parse("August 21, 2010").to_date
        end

        it "should assign query counts for fulltext matches of the query term" do
          assigns[:search_results].should_not be_nil
        end

        it "should assign an alphabetized list of query groups" do
          assigns[:query_groups].should_not be_nil
        end
        
        it "should render the template" do
         response.should render_template 'analytics/query_searches/index', :layout => 'analytics'
        end
      end
      
      context "when there are query groups" do
        before do
          QueryGroup.destroy_all
          QueryGroup.create(:name => 'abc')
          QueryGroup.create(:name => 'def')
        end
        
        it "should assign an alphabetized list of query groups" do
          get :index, :query => "social security", :analytics_search_start_date => "August 11, 2010", :analytics_search_end_date => "August 21, 2010"
          assigns[:query_groups].first.name.should == 'abc'
          assigns[:query_groups].last.name.should == 'def'
        end
      end

      context "when search query terms and bogus start/end dates are passed in" do
        it "should default start/end dates to sensible values" do
          DailyQueryStat.should_receive(:query_counts_for_terms_like).with("social security", 1.month.ago.to_date, Date.yesterday)
          get :index, :query => "social security", :analytics_search_start_date => "whatever", :analytics_search_end_date => "Loren 21, 2010"
          assigns[:start_date].should == 1.month.ago.to_date
          assigns[:end_date].should == Date.yesterday.to_date
        end

      end

      context "when some of the matching query terms contain HTML markup" do
        render_views
        before do
          DailyQueryStat.create(:query => "<b>obama</b>", :day => Date.parse("August 12, 2010"), :times => 100, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'en')
          DailyQueryStat.reindex
        end

        it "should output those query terms without markup" do
          get :index, :query => 'obama', :analytics_search_start_date => "August 11, 2010", :analytics_search_end_date => "August 21, 2010"
          response.body.should contain(/<b>obama<\/b>/)
        end
      end
    end
  end
end
