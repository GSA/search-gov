require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/account.html.haml" do
  fixtures :users, :affiliates
  before do
    @webtrends_tag = 'var _tag=new WebTrends();'
    activate_authlogic
  end
  
  context "when page is displayed" do
    it "should should not show webtrends javascript" do
      render
      response.should_not contain(@webtrends_tag)
    end
    
    it "should show a global SAYT tag" do
      render
      response.should have_tag("script", :text => "\n    //\n    var usagov_sayt_url = \"http://test.host/sayt?\";\n    //\n    ")
    end
  end
  
  context "when an affiliate is present" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      assigns[:affiliate] = @affiliate
    end
    
    it "should output SAYT javascript and CSS tags" do
      render
      response.should have_tag("script", :text => "\n    //\n    var usagov_sayt_url = \"http://test.host/sayt?\";\n    //\n    ")
    end
  end
end