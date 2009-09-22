require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::QuerySearchesController do
  describe "#index" do

    context "when no search query term passed in" do
      before do
        get :index
      end

      it "should redirect to the analytics home page" do
        response.should redirect_to(analytics_home_page_path)
      end
    end

    context "when a search query term is passed in" do
      before do
        DailyQueryStat.should_receive(:most_popular_terms_like).with("social security")
        get :index, :query => "social security"
      end

      it "should set the search query term" do
        assigns[:search_query_term].should == "social security"
      end

      should_render_template 'analytics/query_searches/index.html.haml', :layout => 'analytics'
    end

  end

end
