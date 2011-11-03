require 'spec/spec_helper'

describe AffiliateHelper do
  fixtures :affiliate_templates

  describe "#affiliate_center_breadcrumbs" do
    it "should generate links that contain USASearch > Affiliate Program > Affiliate Center > a title" do
      helper.should_receive(:breadcrumbs).with([link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path), "a title"])
      content = helper.affiliate_center_breadcrumbs("a title")
    end

    it "should generate links that contain USASearch > Affiliate Program > Affiliate Center > a link > a title" do
      helper.should_receive(:breadcrumbs).with([link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path),link_to("a link", "http://blah"), "a title"])
      content = helper.affiliate_center_breadcrumbs([link_to("a link", "http://blah"), "a title"])
    end
  end

  describe "#site_wizard_header" do
    it "should add current_step class based on the current_step parameter" do
      content = helper.site_wizard_header :edit_contact_information
      content.should have_selector("img[alt='Step 1. Enter contact information']")

      content = helper.site_wizard_header :new_site_information
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

      it { should have_selector "a", :href => '#', :class => 'crawled-url-dialog-link', :content => 'Error', :dialog_id => 'crawled-url-error-message-12345' }
      it { should have_selector "span", :class => 'ui-icon ui-icon-newwin' }
      it { should have_selector "div", :class => 'crawled-url-error-message', :id => 'crawled-url-error-message-12345' }
    end
  end
end
