require 'spec/spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = stub('affiliate', :header => 'header', :footer => 'footer', :is_sayt_enabled => false, :is_affiliate_suggestions_enabled => false, :affiliate_template => affiliate_template)
    assign(:affiliate, affiliate)
  end
  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end
end