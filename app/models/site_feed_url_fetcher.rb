class SiteFeedUrlFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(site_feed_url_id)
    return unless (site_feed_url = SiteFeedUrl.find_by_id(site_feed_url_id))
    SiteFeedUrlData.new(site_feed_url).import
  end
end
