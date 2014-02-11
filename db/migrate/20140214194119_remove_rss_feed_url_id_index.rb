class RemoveRssFeedUrlIdIndex < ActiveRecord::Migration
  def up
    remove_index :news_items, :rss_feed_url_id
  end

  def down
    add_index :news_items, :rss_feed_url_id
  end
end
