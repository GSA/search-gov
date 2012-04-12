require 'spec/spec_helper'

describe SitemapObserver do
  fixtures :affiliates

  it "should enqueue the crawling of a sitemap after creation but not updating" do
    ResqueSpec.reset!
    Kernel.stub!(:open).and_return File.open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
    sitemap = affiliates(:basic_affiliate).sitemaps.create!(:url => 'http://www.example.gov/sitemap.xml')
    SitemapFetcher.should have_queued(sitemap.id)
    ResqueSpec.reset!
    sitemap.update_attribute(:url, 'http://www.example.gov/sitemap2.xml')
    SitemapFetcher.should_not have_queued(sitemap.id)
  end

end
