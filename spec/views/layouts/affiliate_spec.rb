require 'spec/spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = stub('affiliate', :exclude_webtrends? => false, :header => 'header', :footer => 'footer', :is_sayt_enabled => false, :is_affiliate_suggestions_enabled => false, :affiliate_template => affiliate_template, :external_css_url => 'http://cdn.agency.gov/custom.css')
    assign(:affiliate, affiliate)
  end
  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end

  context "when exclude_webtrends flag is set to true" do
    before do
      affiliate_template = stub('affiliate template', :stylesheet => 'default')
      affiliate = stub('affiliate', :exclude_webtrends? => true, :header => 'header', :footer => 'footer', :is_sayt_enabled => false, :is_affiliate_suggestions_enabled => false, :affiliate_template => affiliate_template, :external_css_url => 'http://cdn.agency.gov/custom.css')
      assign(:affiliate, affiliate)
    end

    it "should not show webtrends javascript" do
      render
      rendered.should_not have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end
end