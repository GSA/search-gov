class AddRssFeedUrlIdToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :rss_feed_url_id, :integer, :null => false
    add_index :news_items, :rss_feed_url_id
  end

  def self.down
    remove_column :news_items, :rss_feed_url_id
  end
end
