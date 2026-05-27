class DropNewsAndYoutubeTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :news_items, if_exists: true
    drop_table :rss_feed_urls_rss_feeds, if_exists: true
    drop_table :rss_feed_urls, if_exists: true
    drop_table :rss_feeds, if_exists: true
    drop_table :youtube_playlists, if_exists: true
    drop_table :affiliates_youtube_profiles, if_exists: true
    drop_table :youtube_profiles, if_exists: true

    Navigation.where(navigable_type: 'RssFeed').delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
