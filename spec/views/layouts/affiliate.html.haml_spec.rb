require 'spec/spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = mock_model(Affiliate,
                           :is_sayt_enabled? => true,
                           :exclude_webtrends? => false,
                           :header_footer_sass => nil,
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
                           :locale => 'en',
                           :has_custom_webtrends_properties? => false,
                           :ga_web_property_id => nil)
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
                             :header_footer_sass => nil,
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
                             :locale => 'en',
                             :has_custom_webtrends_properties? => false,
                             :ga_web_property_id => nil)
      assign(:affiliate, affiliate)
    end

    it "should not show webtrends javascript" do
      render
      rendered.should_not have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end

  context "when external tracking properties are populated" do
    before do
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => true,
                             :exclude_webtrends? => false,
                             :header_footer_sass => nil,
                             :header => nil,
                             :footer => nil,
                             :css_property_hash => {},
                             :favicon_url => nil,
                             :external_css_url => nil,
                             :uses_one_serp? => true,
                             :page_background_image_file_name => nil,
                             :uses_managed_header_footer? => false,
                             :managed_header_css_properties => nil,
                             :show_content_border? => true,
                             :show_content_box_shadow? => true,
                             :locale => 'en',
                             :has_custom_webtrends_properties? => true,
                             :wt_javascript_url => 'http://search.usa.gov/javascripts/webtrends_english.js',
                             :wt_dcsimg_hash => 'MY_DCSIMG_HASH',
                             :wt_dcssip => 'MY_DCSSIP',
                             :ga_web_property_id => 'UA-XXXXX-XX')
      assign(:affiliate, affiliate)
    end

    it "should show external tracking javascript" do
      render
      rendered.should have_selector("script[src='http://search.usa.gov/javascripts/webtrends_english.js'][type='text/javascript']")
      rendered.should have_selector("img[id='CUSTOM_DCSIMG'][src='//statse.webtrendslive.com/MY_DCSIMG_HASH/njs.gif?dcsuri=/nojavascript&WT.js=No&WT.tv=9.4.0&dcssip=MY_DCSSIP']")
      rendered.should match(Regexp.escape("_gaq.push(['_setAccount', 'UA-XXXXX-XX']);"))
    end
  end
end