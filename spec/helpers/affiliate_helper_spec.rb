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
end
