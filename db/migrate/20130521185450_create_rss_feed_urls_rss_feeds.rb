class CreateRssFeedUrlsRssFeeds < ActiveRecord::Migration
  def change
    create_table :rss_feed_urls_rss_feeds, id: false do |t|
      t.integer :rss_feed_url_id, null: false
      t.integer :rss_feed_id, null: false
    end
    add_index :rss_feed_urls_rss_feeds, [:rss_feed_id, :rss_feed_url_id], unique: true
  end
end