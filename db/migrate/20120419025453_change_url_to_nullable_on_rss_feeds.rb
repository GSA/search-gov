class ChangeUrlToNullableOnRssFeeds < ActiveRecord::Migration
  def self.up
    change_column_null :rss_feeds, :url, true
  end

  def self.down
    change_column_null :rss_feeds, :url, false
  end
end
