class RssFeedFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(rss_feed_url_id, ignore_older_items = true)
    rss_feed_url = RssFeedUrl.find_by_id rss_feed_url_id
    RssFeedData.new(rss_feed_url, ignore_older_items).import if rss_feed_url
  end
end
