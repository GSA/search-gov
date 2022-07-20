# frozen_string_literal: true

class SitemapIndexerJob < ApplicationJob
  queue_as :sitemap
  unique :until_performed

  def perform(sitemap_url:)
    SitemapIndexer.new(sitemap_url: sitemap_url).index
  end
end
