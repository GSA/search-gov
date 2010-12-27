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

      context "when the request is from a web browser" do
        it "should show a 404 error, instead of erroring" do
          get :show, :url_slug => "Some/Topic"
          response.should_not be_success
          response.should render_template("#{RAILS_ROOT}/public/404.html")
        end
      end
      
      context "when the request is from a mobile browser" do
        it "should return a page successfully" do
          get :show, :url_slug => 'Some/Topic', :m => "true"
          response.should be_success
        end
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