require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/admin.html.haml" do
  before do
    @webtrends_tag = 'var _tag=new WebTrends();'
    activate_authlogic
  end
  
  context "when page is displayed" do
    it "should should not show webtrends javascript" do
      render
      response.should_not contain(@webtrends_tag)
    end
  end
  
end