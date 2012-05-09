class UpdateManagedVideoRssFeedUrlsToPending < ActiveRecord::Migration
  def self.up
    unless Rails.env.test?
      ids = RssFeed.managed.videos.collect(&:rss_feed_urls).flatten.collect(&:id)
      RssFeedUrl.update_all "last_crawl_status = '#{RssFeedUrl::PENDING_STATUS}'", :id => ids
    end
  end

  def self.down
  end
end
