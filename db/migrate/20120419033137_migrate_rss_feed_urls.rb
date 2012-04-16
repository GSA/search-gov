class MigrateRssFeedUrls < ActiveRecord::Migration
  def self.up
    RssFeed.all.each do |rss_feed|
      next if rss_feed.url.blank? or rss_feed.rss_feed_urls.present?
      RssFeed.transaction do
        rss_feed_url = rss_feed.rss_feed_urls.create!(:url => rss_feed.url)
        rss_feed.news_items.update_all(:rss_feed_url_id => rss_feed_url.id)
      end
    end unless Rails.env.test?
  end

  def self.down
  end
end
