class AddIsActiveToRssFeeds < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :is_active, :boolean, :default => false
  end

  def self.down
    remove_column :rss_feeds, :is_active
  end
end
