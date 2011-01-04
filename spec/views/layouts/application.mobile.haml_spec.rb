require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/application.mobile.haml" do
  context "when a mobile page is displayed" do
    it "should show the mobile webtrends javascript" do
      template.stub!(:is_device?).and_return false
      render
      response.body.should have_tag("script[src=/javascripts/webtrends_mobile.js][type=text/javascript]")
    end
  end
end