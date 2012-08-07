require 'spec_helper'

describe SitemapFetcher, "#perform(sitemap_id)" do
  fixtures :affiliates
  before do
    @aff = affiliates(:power_affiliate)
    Sitemap.destroy_all
    sitemap = File.open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
    Kernel.stub!(:open).and_return sitemap
    @sitemap = Sitemap.new(:url => 'http://www.example.gov/sitemap.xml', :affiliate => @aff)
    @sitemap.stub!(:open).and_return sitemap
    @sitemap.save!
  end

  context "when it can't locate the Sitemap for a given id" do
    it "should ignore the entry" do
      SitemapFetcher.perform(-1)
    end
  end

  context "when it can locate the Sitemap for an affiliate" do
    before do
      Sitemap.stub!(:find_by_id).and_return @sitemap
    end

    it "should attempt to fetch the sitemap and create indexed_document entries" do
      @sitemap.should_receive(:fetch)
      SitemapFetcher.perform(@sitemap.id)
    end
  end
end