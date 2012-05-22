class RemoveIsNavigableAndPositionFromRssFeeds < ActiveRecord::Migration
  def self.up
    remove_column :rss_feeds, :is_navigable
    remove_column :rss_feeds, :position
  end

  def self.down
    add_column :rss_feeds, :is_navigable, :boolean, :default => false
    add_column :rss_feeds, :position, :integer
  end
end
