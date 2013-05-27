class AddRenderOnlyMediaToRssFeeds < ActiveRecord::Migration
  def change
    add_column :rss_feeds, :show_only_media_content, :boolean, default: false, null: false
  end
end
