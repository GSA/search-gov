class AddShownInGovboxToRssFeeds < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :shown_in_govbox, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :rss_feeds, :shown_in_govbox
  end
end
