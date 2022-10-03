require 'resque-lock-timeout'
class RssFeedFetcher
  extend Resque::Plugins::Priority
  extend Resque::Plugins::LockTimeout
  extend ResqueJobStats

  @queue = :primary
  @loner = true
  @lock_timeout = 3600

  def self.perform(rss_feed_url_id, ignore_older_items = true)
    rss_feed_url = RssFeedUrl.find_by_id rss_feed_url_id
    RssFeedData.new(rss_feed_url, ignore_older_items).import if rss_feed_url
  end
end
