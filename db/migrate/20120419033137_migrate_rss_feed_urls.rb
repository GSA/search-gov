class MigrateRssFeedUrls < ActiveRecord::Migration
  def self.up
    RssFeed.all.each do |rss_feed|
      next if rss_feed.url.blank? or rss_feed.rss_feed_urls.present?
      RssFeed.transaction do
        rss_feed_url = rss_feed.rss_feed_urls.build(:url => rss_feed.url)
        rss_feed.news_items.update_all(:rss_feed_url_id => rss_feed_url.id) if rss_feed_url.save
      end
    end unless Rails.env.test?
  end

  def self.down
  end
end
