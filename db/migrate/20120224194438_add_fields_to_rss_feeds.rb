class AddFieldsToRssFeeds < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :last_crawled_at, :datetime
    add_column :rss_feeds, :last_crawl_status, :string
  end

  def self.down
    remove_column :rss_feeds, :last_crawl_status
    remove_column :rss_feeds, :last_crawled_at
  end
end
