class RemoveRssFeedIdFromNewsItem < ActiveRecord::Migration
  def up
    remove_column :news_items, :rss_feed_id
  end

  def down
    add_column :news_items, :rss_feed_id, :integer
  end
end
