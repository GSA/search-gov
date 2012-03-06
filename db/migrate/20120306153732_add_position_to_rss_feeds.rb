class AddPositionToRssFeeds < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :position, :integer
  end

  def self.down
    remove_column :rss_feeds, :position
  end
end
