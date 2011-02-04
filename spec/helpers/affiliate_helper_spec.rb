require "#{File.dirname(__FILE__)}/../spec_helper"

describe AffiliateHelper do
  describe "#affiliate_center_breadcrumbs" do
    it "should generate links that contain USASearch > Affiliate Program > Affiliate Center > a title" do
      content = helper.affiliate_center_breadcrumbs("a title")
      content.should have_tag("a", "USASearch")
      content.should have_tag("a", "Affiliate Program")
      content.should have_tag("a", "Affiliate Center")
      content.should contain("a title")
    end

    it "should generate links that contain USASearch > Affiliate Program > Affiliate Center > a link > a title" do
      content = helper.affiliate_center_breadcrumbs([link_to("a link", "http://blah"), "a title"])
      content.should have_tag("a", "USASearch")
      content.should have_tag("a", "Affiliate Program")
      content.should have_tag("a", "Affiliate Center")
      content.should have_tag("a", "a link")
      content.should contain("a title")
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
