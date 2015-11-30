class AddIndexWithRssFeedUrlIdAndGuid < ActiveRecord::Migration
  def self.up
    add_index :news_items, [:rss_feed_url_id, :guid]
  end

  def self.down
    remove_index :news_items, [:rss_feed_url_id, :guid]
  end
end
