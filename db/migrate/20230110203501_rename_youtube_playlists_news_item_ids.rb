class RenameYoutubePlaylistsNewsItemIds < ActiveRecord::Migration[7.0]
  def change
    change_table :youtube_playlists, bulk: true do |t|
      t.rename :news_item_ids, :unsafe_news_item_ids
      t.rename :safe_news_item_ids, :news_item_ids
    end
  end
end
