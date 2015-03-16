class CreateYoutubePlaylists < ActiveRecord::Migration
  def change
    create_table :youtube_playlists do |t|
      t.integer :youtube_profile_id
      t.string :playlist_id
      t.string :etag
      t.text :news_item_ids, limit: 20.megabytes

      t.timestamps
    end
    add_index :youtube_playlists, [:youtube_profile_id, :playlist_id], unique: true
  end
end
