class DropLegacyRssFeedUrls < ActiveRecord::Migration
  def up
    drop_table :legacy_rss_feed_urls
  end

  def down
    create_table "legacy_rss_feed_urls", :force => true do |t|
      t.integer  "rss_feed_id",                              :null => false
      t.string   "url",                                      :null => false
      t.datetime "last_crawled_at"
      t.string   "last_crawl_status", :default => "Pending", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "legacy_rss_feed_urls", ["rss_feed_id"], :name => "index_rss_feed_urls_on_rss_feed_id"
  end
end
