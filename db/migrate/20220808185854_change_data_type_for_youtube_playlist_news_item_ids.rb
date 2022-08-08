class ChangeDataTypeForYoutubePlaylistNewsItemIds < ActiveRecord::Migration[6.1]
  def up
    # create a faux model to avoid JSON parsing of still-YAML content
    faux_youtube_playlists = Class.new ActiveRecord::Base
    faux_youtube_playlists.table_name = 'youtube_playlists'

    faux_youtube_playlists.select([:id, :news_item_ids]).find_in_batches do |youtube_playlists|
     youtube_playlists.each do |youtube_playlist|
        begin
         next if youtube_playlist.news_item_ids.nil?

          youtube_playlist.news_item_ids = YAML.load(youtube_playlist.news_item_ids).to_json
          youtube_playlist.save!

        rescue Exception => e
          puts "Could not fix youtube playlist #{youtube_playlist.id} for #{e.message}"
        end
      end
    end

    change_column :youtube_playlists, :news_item_ids, :json
 end

 def down
   change_column :youtube_playlists, :news_item_ids, :text
 end
end
