class SitemapIndexerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(sitemap_url:)
    SitemapIndexer.new(sitemap_url: sitemap_url).index
  end
end
