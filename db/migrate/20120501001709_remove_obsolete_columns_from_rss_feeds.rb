class RemoveObsoleteColumnsFromRssFeeds < ActiveRecord::Migration
  def self.up
    remove_column :rss_feeds, :url
    remove_column :rss_feeds, :last_crawled_at
    remove_column :rss_feeds, :last_crawl_status
  end

  def self.down
    add_column :rss_feeds, :last_crawl_status, :string
    add_column :rss_feeds, :last_crawled_at, :datetime
    add_column :rss_feeds, :url, :string
  end
end
