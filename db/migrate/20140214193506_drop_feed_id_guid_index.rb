class DropFeedIdGuidIndex < ActiveRecord::Migration
  def up
    remove_index :news_items, [:rss_feed_id, :guid]
  end

  def down
    add_index :news_items, [:rss_feed_id, :guid]
  end
end
