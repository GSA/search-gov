class AddIsManagedToRssFeeds < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :is_managed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :rss_feeds, :is_managed
  end
end
