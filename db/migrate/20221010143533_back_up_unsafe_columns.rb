class BackUpUnsafeColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :watchers, :safe_conditions, :json
    add_column :news_items, :safe_properties, :json
    add_column :tweets, :safe_urls, :json
    add_column :twitter_lists, :safe_member_ids, :json
    add_column :youtube_playlists, :safe_news_item_ids, :json
  end
end
