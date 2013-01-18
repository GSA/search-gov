require 'spec_helper'

describe Sitemap do
  fixtures :affiliates, :features

  before do
    affiliates(:power_affiliate).site_domains.create!(:domain => 'example.gov')
    @valid_attributes = {
      :url => 'http://www.example.gov/sitemap.xml',
      :affiliate_id => affiliates(:power_affiliate).id
    }
  end

  context "when creating a new Sitemap" do
    context "when the URL points to a valid sitemap" do
      before do
        sitemap = File.open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
        Kernel.stub!(:open).and_return sitemap
        Sitemap.create!(@valid_attributes)
      end

      it { should validate_presence_of :url }
      it { should validate_uniqueness_of(:url).scoped_to(:affiliate_id) }
      it { should belong_to(:affiliate) }
    end

    context "when the URL points to an invalid sitemap" do
      before do
        sitemap = File.open(Rails.root.to_s + "/spec/fixtures/rss/wh_blog.xml")
        Kernel.stub!(:open).and_return sitemap
      end

      it "should generate errors stating the sitemap is invalid" do
        sitemap = Sitemap.create(@valid_attributes)
        sitemap.errors.should_not be_empty
        sitemap.errors.first.last.should == "The Sitemap URL specified does not appear to be a valid Sitemap."
      end
    end

    context "when there is some error in crawling the sitemap" do
      before do
        Kernel.stub!(:open).and_raise "Some error!"
      end

      it "should pass on the error information in the error message" do
        sitemap = Sitemap.create(@valid_attributes)
        sitemap.errors.should_not be_empty
        sitemap.errors.first.last.should == "The Sitemap URL specified does not appear to be a valid Sitemap.  Additional information: Some error!"
      end
    end
  end

end
