require 'spec/spec_helper'

describe ErrorsController do
  context "when handling a mobile request" do
    before do
      iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
      get "/page_not_found", {}, { "HTTP_USER_AGENT" => iphone_user_agent }
    end

    it "should response with 404" do
      response.status.should == 404
    end
    
    it "should render the simple 404 page" do
      response.body.should contain(/The page you were looking for doesn't exist./)
      response.body.should contain(/You may have mistyped the address or the page may have moved./)
    end
  end
end