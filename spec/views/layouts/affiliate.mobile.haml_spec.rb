require 'spec/spec_helper'
describe "layouts/affiliate.mobile.haml" do
  before do
    view.stub!(:is_device?).and_return false
  end

  context "when external tracking properties are populated" do
    before do
      affiliate = mock_model(Affiliate,
                             :display_name => 'mock site',
                             :is_sayt_enabled? => true,
                             :exclude_webtrends? => false,
                             :header_footer_sass => nil,
                             :header => nil,
                             :footer => nil,
                             :css_property_hash => {},
                             :favicon_url => nil,
                             :external_css_url => nil,
                             :uses_one_serp? => true,
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
