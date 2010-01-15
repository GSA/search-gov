require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do
  fixtures :affiliates

  describe "#auto_complete_for_search_query" do
    it "should use query param to find terms starting with that param" do
      DailyQueryStat.should_receive(:find).with(:all, :conditions => ["query LIKE ?", "foo%"], :order => 'query ASC', :limit => 15, :select=>"distinct(query) as query")
      get :auto_complete_for_search_query, :query=>"foo"
    end

    it "should not completely melt down when strange characters are present" do
      lambda {get :auto_complete_for_search_query, :query=>"foo\\"}.should_not raise_error
      lambda {get :auto_complete_for_search_query, :query=>"foo's"}.should_not raise_error
    end

    context "when suggestions contain apostrophes" do
      before do
        DailyQueryStat.create(:query=>"oba'ma",:times=>1, :day=>Date.today)
      end

      it "should handle highlighting apostrophe in suggestions" do
        get :auto_complete_for_search_query, :query=>"oba'"
        response.body.should == "<ul><li><strong class=\"highlight\">oba'</strong>ma</li></ul>"
      end
    end

    it "should return empty result if no search param present" do
      get :auto_complete_for_search_query
      response.body.should be_blank
    end

    it "should filter block words from suggestions" do
      BlockWord.should_receive(:filter).once
      get :auto_complete_for_search_query, :query=>"foo"
    end
  end

  describe "when showing index" do
    it "should have a route with a locale" do
      search_path.should == '/search?locale=en'
    end
  end

  describe "when showing a new search" do
    before do
      get :index, :query => "social security", :page => 4
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

  end

  context "when handling a valid affiliate search request" do
    integrate_views
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
