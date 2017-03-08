class InactiveRssFeedUrlDestroyer
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(rss_feed_url_id)
    rss_feed_url = RssFeedUrl.find_by_id(rss_feed_url_id)
    rss_feed_url.destroy if rss_feed_url && rss_feed_url.rss_feeds.blank?
  end
end
