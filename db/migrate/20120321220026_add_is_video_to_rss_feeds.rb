class AddIsVideoToRssFeeds < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :is_video, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :rss_feeds, :is_video
  end
end
