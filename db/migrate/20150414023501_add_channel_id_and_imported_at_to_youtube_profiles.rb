class AddChannelIdAndImportedAtToYoutubeProfiles < ActiveRecord::Migration
  class YoutubeProfile < ActiveRecord::Base
  end

  def up
    add_column :youtube_profiles, :channel_id, :string, null: false
    YoutubeProfile.reset_column_information
    YoutubeProfile.update_all 'channel_id = title'
    add_index :youtube_profiles, :channel_id, unique: true

    add_column :youtube_profiles, :imported_at, :datetime
    add_index :youtube_profiles, [:id, :imported_at]
  end

  def down
    remove_index :youtube_profiles, [:id, :imported_at]
    remove_column :youtube_profiles, :imported_at
    remove_column :youtube_profiles, :channel_id
  end
end
