require 'spec/spec_helper'

describe AffiliateHelper do
  describe "#affiliate_center_breadcrumbs" do
    it "should generate links that contain USASearch > Admin Center > a title" do
      helper.should_receive(:breadcrumbs).with([link_to("Admin Center",home_affiliates_path), "a title"])
      helper.affiliate_center_breadcrumbs("a title")
    end

    it "should generate links that contain USASearch > Admin Center > a link > a title" do
      helper.should_receive(:breadcrumbs).with([link_to("Admin Center",home_affiliates_path),link_to("a link", "http://blah"), "a title"])
      helper.affiliate_center_breadcrumbs([link_to("a link", "http://blah"), "a title"])
    end
  end

  describe "#site_wizard_header" do
    it "should add current_step class based on the current_step parameter" do
      content = helper.site_wizard_header :basic_settings
      content.should have_selector("img[alt='Step 1. Basic Settings']")

      content = helper.site_wizard_header :content_sources
      content.should have_selector("img[alt='Step 2. Set up site']")

      content = helper.site_wizard_header :get_the_code
      content.should have_selector("img[alt='Step 3. Get the code']")
    end
  end

  describe "#render_staged_color_text_field_tag" do
    let(:affiliate) { mock_model(Affiliate, :staged_theme => 'natural', :staged_css_property_hash => { :left_tab_text_color => Affiliate::THEMES[:natural][:left_tab_text_color] }) }

    context "when staged_theme is not custom" do
      subject { helper.render_staged_color_text_field_tag(affiliate, :left_tab_text_color) }

      it { should have_selector "input", :disabled => 'disabled', :value => '#B58100' }
    end
  end

  describe "#render_managed_header" do
    context "when the affiliate has a header image and an exception occurs when trying to retrieve the image" do
      let(:header_image) { mock('header image') }
      let(:affiliate) { mock_model(Affiliate,
                                   :header_image_file_name => 'logo.gif',
                                   :header_image => header_image,
                                   :managed_header_text => nil,
                                   :managed_header_home_url => nil,
                                   :managed_header_css_properties => Affiliate::DEFAULT_MANAGED_HEADER_CSS_PROPERTIES) }

      before do
        header_image.should_receive(:url).and_raise
      end

      specify { helper.render_managed_header(affiliate).should_not have_select(:img) }
    end
  end

  describe "#render_affiliate_body_style" do
    context "when CloudFiles raise NoSuchContainer" do
      let(:affiliate) { mock_model(Affiliate, :css_property_hash => {}, :page_background_image_file_name => 'bg.png')}
      it "should return only background-color" do
        helper.should_receive(:render_affiliate_css_property_value).with({}, :page_background_color).and_return('#DDDDDD')
        affiliate.should_receive(:page_background_image).and_raise(CloudFiles::Exception::NoSuchContainer)
        helper.render_affiliate_body_style(affiliate).should == 'background-color: #DDDDDD'
      end
    end
  end
end
