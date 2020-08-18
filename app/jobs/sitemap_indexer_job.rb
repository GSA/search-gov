class SitemapIndexerJob < ApplicationJob
  queue_as :sitemap

  def perform(sitemap_url:)
    SitemapIndexer.new(sitemap_url: sitemap_url).index
  end
end
