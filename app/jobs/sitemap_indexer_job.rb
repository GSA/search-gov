# frozen_string_literal: true

class SitemapIndexerJob < ApplicationJob
  queue_as :sitemap
  unique :until_performed

  # def perform(sitemap_url:)
  #   SitemapIndexer.new(sitemap_url: sitemap_url).index
  # end
  # New version -DJMII
  def perform(sitemap_url:, domain:)
    SitemapIndexer.new(sitemap_url: sitemap_url, domain: domain).index
  end
end
