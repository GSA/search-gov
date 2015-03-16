class RenameUsernameToTitleOnYoutubeProfiles < ActiveRecord::Migration
  def up
    remove_index :youtube_profiles, :username
    rename_column :youtube_profiles, :username, :title
  end

  def down
    rename_column :youtube_profiles, :title, :username
    add_index :youtube_profiles, :username, unique: true
  end
end
