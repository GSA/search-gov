class RenameRssFeedUrlsToLegacyRssFeedUrls < ActiveRecord::Migration
  def change
    rename_table :rss_feed_urls, :legacy_rss_feed_urls
  end
end
