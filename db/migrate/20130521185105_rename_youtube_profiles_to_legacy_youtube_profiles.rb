class RenameYoutubeProfilesToLegacyYoutubeProfiles < ActiveRecord::Migration
  def change
    rename_table :youtube_profiles, :legacy_youtube_profiles
  end
end
