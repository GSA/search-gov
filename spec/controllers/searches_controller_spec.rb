require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do
  fixtures :affiliates
  integrate_views

  describe "#auto_complete_for_search_query" do
    it "should use query param to find terms starting with that param" do
      DailyQueryStat.should_receive(:find).with(:all, :conditions => ["query LIKE ?", "foo%"], :order => 'query ASC', :limit => 15, :select=>"distinct(query) as query")
      get :auto_complete_for_search_query, :query=>"foo"
    end
  end

  describe "when showing index" do
    it "should have a route" do
      search_path.should == '/search'
    end

  end

  describe "when showing a new search" do
    before do
      get :index, :query => "social security", :page => 4, :engine => "gss"
      @search = assigns[:search]
    end

    should_render_template 'searches/index.html.haml', :layout => 'application'

    it "should set the query in the Search model" do
      @search.query.should == "social security"
    end

    it "should offset the start page in the Search model by one" do
      @search.page.should == 3
    end

    it "should load results for a keyword query" do
      @search.should_not be_nil
      @search.results.should_not be_nil
    end

    it "should set the search engine" do
      @search.engine.class.to_s.downcase.should == "gss"
    end
  end

  context "when handling a valid affiliate search request" do
    before do
      @affiliate = affiliates(:power_affiliate)
      get :index, :affiliate=>@affiliate.name, :query => "weather"
    end

    should_assign_to :affiliate
    should_assign_to :page_title

    should_render_template 'searches/affiliate_index.html.haml', :layout => 'affiliate'

    it "should render the header in the response" do
      response.body.should match(/#{@affiliate.header}/)
    end

    it "should render the footer in the response" do
      response.body.should match(/#{@affiliate.footer}/)
    end

  end

  context "when handling an invalid affiliate search request" do
    before do
      get :index, :affiliate=>"doesnotexist.gov", :query => "weather"
      @search = assigns[:search]
    end

    should_render_template 'searches/index.html.haml', :layout => 'application'

  end
end
