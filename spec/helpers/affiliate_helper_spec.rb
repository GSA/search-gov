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
end
