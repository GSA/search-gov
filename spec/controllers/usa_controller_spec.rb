require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsaController do
  fixtures :site_pages

  describe "#show" do
    it "should get url_slug param from URL" do
      params_from(:get, "/usa/Some/Topic/index").should == {:controller => "usa", :action => "show", :url_slug => "Some/Topic/index"}
    end

    it "should assign the @search instance" do
      get :show, :url_slug=>"Some/Topic"
      assigns[:search].should be_instance_of(Search)
    end

    it "should assign the @site_page instance" do
      get :show, :url_slug=>"Some/Topic"
      assigns[:site_page].should be_instance_of(SitePage)
    end

    it "should assign the @title from the appropriate site_page" do
      get :show, :url_slug=>"Some/Topic"
      assigns[:title].should == "Some Topic"
    end
  end
end