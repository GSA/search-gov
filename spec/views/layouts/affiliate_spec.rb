require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/affiliate" do
  before do
    @webtrends_tag = 'var _tag=new WebTrends();'
  end
  
  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      response.should contain(@webtrends_tag)
    end
  end
  
end