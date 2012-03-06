class RenameIsActiveToIsNavigableOnRssFeeds < ActiveRecord::Migration
  def self.up
    rename_column :rss_feeds, :is_active, :is_navigable
  end

  def self.down
    rename_column :rss_feeds, :is_navigable, :is_active
  end
end
