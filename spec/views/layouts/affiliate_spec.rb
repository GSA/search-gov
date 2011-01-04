require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/affiliate" do
  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      response.body.should have_tag("script[src=/javascripts/webtrends_affiliates.js][type=text/javascript]")
    end
  end
end