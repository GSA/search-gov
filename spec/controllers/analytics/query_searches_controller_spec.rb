require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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

        it "should assign query counts for fulltext matches of the query term" do
          assigns[:search_results].should_not be_nil
        end

        should_render_template 'analytics/query_searches/index.html.haml', :layout => 'analytics'
      end

      context "when some of the matching query terms contain HTML markup" do
        integrate_views
        before do
          DailyQueryStat.create(:query => "<b>obama</b>", :day => Date.parse("August 12, 2010"), :times => 100, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME, :locale => 'en')
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
