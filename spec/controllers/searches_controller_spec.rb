require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do

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

  context "when handling a legacy affiliate search request" do
    it "should return results for legacy affiliate search requests" do
      get :index, :affiliate=>"osdpd.noaa.gov", "v:project".to_sym => "firstgov", :query => "selden"
      assigns[:search].results.should_not be_nil
    end
  end

end
