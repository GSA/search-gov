require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsaController do

  describe "#show" do
    context "when page exists for a slug" do
      fixtures :site_pages

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

    context "when page does not exist for a slug" do
      it "should redirect to the home page" do
        get :show, :url_slug=>"Some/Topic/That/Is/Not/There"
        response.should redirect_to(home_page_path)
      end
    end
  end
end