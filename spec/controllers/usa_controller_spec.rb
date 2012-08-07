require 'spec_helper'

describe UsaController do
  render_views

  describe "#show" do
    context "when page exists for a slug" do
      fixtures :site_pages

      context "when the request is from a mobile browser" do
        before do
          iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
          request.env["HTTP_USER_AGENT"] = iphone_user_agent
        end

        it "should return a page successfully" do
          get :show, :url_slug => 'Some/Topic'
          response.should be_success
        end

        it "should get url_slug param from URL" do
          { :get => "/usa/Some/Topic/index"}.should route_to(:controller => "usa", :action => "show", :url_slug => "Some/Topic/index")
        end

        it "should assign the @search instance" do
          get :show, :url_slug=>"Some/Topic", :m => "true"
          assigns[:search].should be_instance_of(WebSearch)
        end

        it "should assign the @site_page instance" do
          get :show, :url_slug=>"Some/Topic"
          assigns[:site_page].should be_instance_of(SitePage)
        end

        it "should assign the @title from the appropriate site_page" do
          get :show, :url_slug=>"Some/Topic"
          assigns[:title].should == "Some Topic"
        end

        context "when page does not exist for a slug" do
          it "should redirect to the home page" do
            get :show, :url_slug=>"Some/Topic/That/Is/Not/There"
            response.should redirect_to(home_page_path)
          end
        end

        context "for a spanish page" do
          it "should link to the spanish homepage" do
            get :show, :url_slug => site_pages(:two).url_slug
            response.should have_selector("a[href='http://gobiernousa.gov/?mobile-opt-out=true'][title='USA.gov']", :content => 'Web')
          end
        end
      end

      context "when the request is from a web browser" do
        it "should still render the mobile version of the page" do
          get :show, :url_slug => "Some/Topic"
          response.should be_success
        end
      end
    end
  end
end