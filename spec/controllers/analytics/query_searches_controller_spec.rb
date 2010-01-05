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
          DailyQueryStat.should_receive(:most_popular_terms_like).with("social security", true)
          get :index, :query => "social security", :search_type=> "starts_with"
        end

        it "should set the search query term" do
          assigns[:search_query_term].should == "social security"
        end

        should_render_template 'analytics/query_searches/index.html.haml', :layout => 'analytics'
      end

      context "when a search query term is passed in for results that contain the search query term" do
        it "should find most popular terms containing that string" do
          DailyQueryStat.should_receive(:most_popular_terms_like).with("social security", false)
          get :index, :query => "social security", :search_type=> "contains"
        end

        it "should set the starts_with flag to false" do
          get :index, :query => "social security", :search_type=> "contains"
          assigns[:starts_with].should be_false
        end
      end

      context "when a search query term is passed in for results that start with the search query term" do
        it "should find most popular terms starting with that string" do
          DailyQueryStat.should_receive(:most_popular_terms_like).with("social security", true)
          get :index, :query => "social security", :search_type=> "starts_with"
        end

        it "should set the starts_with flag to true" do
          get :index, :query => "social security", :search_type=> "starts_with"
          assigns[:starts_with].should be_true
        end
      end
    end
  end
end
