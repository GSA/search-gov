class RecreateRssFeedUrls < ActiveRecord::Migration
  def change
    create_table :rss_feed_urls do |t|
      t.string :rss_feed_owner_type, null: false
      t.string :url, null: false
      t.datetime :last_crawled_at
      t.string :last_crawl_status, default: 'Pending', null: false

      t.timestamps
    end
    add_index :rss_feed_urls, [:rss_feed_owner_type, :url], unique: true
  end
end