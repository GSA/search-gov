class ChangeNewsItems < ActiveRecord::Migration
  def up
    change_column_null :news_items, :rss_feed_id, true
    add_index :news_items, [:rss_feed_url_id, :link], unique: true
  end

  def down
    remove_index :news_items, column: [:rss_feed_url_id, :link]
    change_column_null :news_items, :rss_feed_id, false
  end
end
