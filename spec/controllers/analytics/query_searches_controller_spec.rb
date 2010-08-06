require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::QuerySearchesController do
  fixtures :users

  context "when logged in as an analyst" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("analyst").email, :password => "admin")
    end

    describe "#index" do

      context "when a search query term is passed in" do
        before do
          get :index, :query => "social security"
        end

        it "should set the search query term" do
          assigns[:search_query_term].should == "social security"
        end

        it "should assign query counts for fulltext matches of the query term" do
          assigns[:search_results].should_not be_nil
        end

        should_render_template 'analytics/query_searches/index.html.haml', :layout => 'analytics'
      end

    end
  end
end
