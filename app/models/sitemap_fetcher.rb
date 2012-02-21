class SitemapFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(sitemap_id)
    return unless (sitemap = Sitemap.find_by_id(sitemap_id))
    sitemap.fetch
  end
end