require 'spec/spec_helper'

describe AffiliateHelper do
  fixtures :affiliate_templates

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

  describe "#render_choose_site_templates" do
    it "should display radio button, label and image for the template" do
      content = helper.render_choose_site_templates Affiliate.new
      content.should have_selector("input[name='affiliate[staged_affiliate_template_id]'][value='#{affiliate_templates(:default).id}'][checked='checked']")
      content.should have_selector("input[name='affiliate[staged_affiliate_template_id]'][value='#{affiliate_templates(:basic_gray).id}']")
    end

    it "should have default affiliate template checked if staged_affiliate_template is set to default" do
      content = helper.render_choose_site_templates(Affiliate.new(:staged_affiliate_template => affiliate_templates(:default)))
      content.should have_selector("input[name='affiliate[staged_affiliate_template_id]'][value='#{affiliate_templates(:default).id}'][checked='checked']")
      content.should have_selector("input[name='affiliate[staged_affiliate_template_id]'][value='#{affiliate_templates(:basic_gray).id}']")
    end

    it "should have basic gray affiliate template checked if staged_affiliate_template is set to basic gray" do
      content = helper.render_choose_site_templates(Affiliate.new(:staged_affiliate_template => affiliate_templates(:basic_gray)))
      content.should have_selector("input[name='affiliate[staged_affiliate_template_id]'][value='#{affiliate_templates(:default).id}']")
      content.should have_selector("input[name='affiliate[staged_affiliate_template_id]'][value='#{affiliate_templates(:basic_gray).id}'][checked='checked']")
    end
  end

  describe "#render_last_crawl_status" do
    let(:indexed_document) { mock('indexed document') }
    context "when last crawled status is OK" do
      before do
        indexed_document.should_receive(:last_crawl_status).with(no_args).twice.and_return(IndexedDocument::OK_STATUS)
      end

      specify { helper.render_last_crawl_status(indexed_document).should == IndexedDocument::OK_STATUS }
    end

    context "when last crawl status is blank" do
      before do
        indexed_document.should_receive(:last_crawl_status).with(no_args).exactly(3).times.and_return(nil)
      end

      specify { helper.render_last_crawl_status(indexed_document).should be_nil }
    end

    context "when last crawl status starts with Error|" do
      before do
        indexed_document.should_receive(:id).with(no_args).and_return('12345')
        indexed_document.should_receive(:url).with(no_args).and_return('http://some.domain.gov/blog/1')
        indexed_document.should_receive(:last_crawl_status).with(no_args).exactly(3).times.and_return("404 Not Found")
      end

      subject { helper.render_last_crawl_status(indexed_document) }

      it { should have_selector "a", :href => '#', :class => 'dialog-link', :content => 'Error', :dialog_id => 'crawled_url_error_12345' }
      it { should have_selector "span", :class => 'ui-icon ui-icon-newwin' }
      it { should have_selector "div", :class => 'url-error-message hide', :id => 'crawled_url_error_12345' }
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
    context "when the site uses_one_serp is set to false" do
      let(:affiliate) { mock_model(Affiliate) }
      it "should return blank" do
        affiliate.should_receive(:uses_one_serp?).and_return(false)
        helper.render_affiliate_body_style(affiliate).should be_blank
      end
    end

    context "when CloudFiles raise NoSuchContainer" do
      let(:affiliate) { mock_model(Affiliate, :uses_one_serp? => true, :css_property_hash => {}, :page_background_image_file_name => 'bg.png')}
      it "should return only background-color" do
        helper.should_receive(:render_affiliate_css_property_value).with({}, :page_background_color).and_return('#DDDDDD')
        affiliate.should_receive(:page_background_image).and_raise(CloudFiles::Exception::NoSuchContainer)
        helper.render_affiliate_body_style(affiliate).should == 'background-color: #DDDDDD'
      end
    end
  end
end
