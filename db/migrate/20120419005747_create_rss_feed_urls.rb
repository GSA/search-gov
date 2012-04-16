class CreateRssFeedUrls < ActiveRecord::Migration
  def self.up
    create_table :rss_feed_urls do |t|
      t.references :rss_feed, :null => false
      t.string :url, :null => false
      t.timestamp :last_crawled_at
      t.string :last_crawl_status, :null => false, :default => 'Pending'

      t.timestamps
    end
    add_index :rss_feed_urls, :rss_feed_id
  end

  def self.down
    drop_table :rss_feed_urls
  end
end
