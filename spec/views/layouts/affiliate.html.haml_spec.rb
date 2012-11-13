require 'spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate = mock_model(Affiliate,
                           :is_sayt_enabled? => true,
                           :exclude_webtrends? => false,
                           :nested_header_footer_css => nil,
                           :header => 'header',
                           :footer => 'footer',
                           :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                           :external_css_url => 'http://cdn.agency.gov/custom.css',
                           :css_property_hash => {},
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
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => true,
                             :exclude_webtrends? => true,
                             :header => 'header',
                             :nested_header_footer_css => nil,
                             :footer => 'footer',
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_property_hash => {},
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

  context 'when SAYT is not enabled and @search is a News Search' do
    before do
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => false,
                             :exclude_webtrends? => false,
                             :nested_header_footer_css => nil,
                             :header => 'header',
                             :footer => 'footer',
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_property_hash => { },
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
      search = mock(NewsSearch, query: 'america')
      search.should_receive(:is_a?).with(NewsSearch).and_return(true)
      assign(:search, search)
    end

    it 'should include jquery-ui library' do
      render
      rendered.should have_selector("link[href^='/stylesheets/jquery-ui/jquery-ui.custom.css'][type='text/css']")
      rendered.should have_selector("script[src^='/javascripts/jquery/jquery-ui.custom.min.js'][type='text/javascript']")
    end
  end
end