require 'spec/spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = mock_model(Affiliate,
                           :is_sayt_enabled? => true,
                           :exclude_webtrends? => false,
                           :nested_header_footer_css => nil,
                           :header => 'header',
                           :footer => 'footer',
                           :affiliate_template => affiliate_template,
                           :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                           :external_css_url => 'http://cdn.agency.gov/custom.css',
                           :css_property_hash => {},
                           :uses_one_serp? => true,
                           :page_background_image_file_name => nil,
                           :uses_managed_header_footer? => false,
                           :managed_header_css_properties => nil,
                           :show_content_border? => true,
                           :show_content_box_shadow? => true,
                           :connections => [],
                           :locale => 'en',
                           :ga_web_property_id => nil,
                           :external_tracking_code => nil)
    assign(:affiliate, affiliate)
    search = mock(WebSearch, :query => 'america')
    assign(:search, search)
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
                             :nested_header_footer_css => nil,
                             :footer => 'footer',
                             :affiliate_template => affiliate_template,
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_property_hash => {},
                             :uses_one_serp? => true,
                             :page_background_image_file_name => nil,
                             :uses_managed_header_footer? => false,
                             :managed_header_css_properties => nil,
                             :show_content_border? => true,
                             :show_content_box_shadow? => true,
                             :connections => [],
                             :locale => 'en',
                             :ga_web_property_id => nil,
                             :external_tracking_code => nil)
      assign(:affiliate, affiliate)
    end

    it "should not show webtrends javascript" do
      render
      rendered.should_not have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end
end