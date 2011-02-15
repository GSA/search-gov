require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe WidgetsController do
  before do
    @active_top_searches = []
    TopSearch.should_receive(:find_active_entries).and_return(@active_top_searches)
  end

  describe "#top_searches" do
    it "should assign the top searches to the top 5 positions" do
      get :top_searches
      assigns[:active_top_searches].should == @active_top_searches
    end
  end

  describe "#trending_searches" do
    it "should assign the top searches to the top 5 positions" do
      get :trending_searches
      assigns[:active_top_searches].should == @active_top_searches
    end

    it "should render trending_searches partial" do
      get :trending_searches
      response.should render_template('shared/_trending_searches')
    end
  end
end

