require 'spec/spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = mock_model(Affiliate,
                           :is_sayt_enabled? => true,
                           :exclude_webtrends? => false,
                           :header => 'header',
                           :footer => 'footer',
                           :affiliate_template => affiliate_template,
                           :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                           :external_css_url => 'http://cdn.agency.gov/custom.css',
                           :css_property_hash => {},
                           :uses_one_serp? => true)
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
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => true,
                             :exclude_webtrends? => true,
                             :header => 'header',
                             :footer => 'footer',
                             :affiliate_template => affiliate_template,
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_property_hash => {},
                             :uses_one_serp? => true)
      assign(:affiliate, affiliate)
    end

    it "should not show webtrends javascript" do
      render
      rendered.should_not have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end
end