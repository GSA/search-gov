require "#{File.dirname(__FILE__)}/../spec_helper"

describe AffiliateHelper do
  describe "#affiliate_center_breadcrumbs" do
    it "should generate links that contain USASearch > Affiliate Program > Affiliate Center > a title" do
      helper.should_receive(:default_url_options).at_least(1).and_return({:locale => I18n.locale, :m => "false"})
      helper.should_receive(:breadcrumbs).with([link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path), "a title"])
      content = helper.affiliate_center_breadcrumbs("a title")
    end

    it "should generate links that contain USASearch > Affiliate Program > Affiliate Center > a link > a title" do
      helper.should_receive(:default_url_options).at_least(1).and_return({:locale => I18n.locale, :m => "false"})
      helper.should_receive(:breadcrumbs).with([link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path),link_to("a link", "http://blah"), "a title"])
      content = helper.affiliate_center_breadcrumbs([link_to("a link", "http://blah"), "a title"])
    end
  end

  describe "#site_wizard_header" do
    it "should add current_step class based on the current_step parameter" do
      content = helper.site_wizard_header :edit_contact_information
      content.should have_tag("span[class=step current_step]", "Step 1. Enter contact information")
      content.should have_tag("span[class=step]", "Step 2. Set up site")
      content.should have_tag("span[class=step]", "Step 3. Get the code")
      content = helper.site_wizard_header :new_site_information
      content.should have_tag("span[class=step]", "Step 1. Enter contact information")
      content.should have_tag("span[class=step current_step]", "Step 2. Set up site")
      content.should have_tag("span[class=step]", "Step 3. Get the code")
      content = helper.site_wizard_header :get_the_code
      content.should have_tag("span[class=step]", "Step 1. Enter contact information")
      content.should have_tag("span[class=step]", "Step 2. Set up site")
      content.should have_tag("span[class=step current_step]", "Step 3. Get the code")
    end
  end
end
