class CreateAffiliatesYoutubeProfiles < ActiveRecord::Migration
  def change
    create_table :affiliates_youtube_profiles, id: false do |t|
      t.integer :affiliate_id
      t.integer :youtube_profile_id
    end
    add_index :affiliates_youtube_profiles, [:affiliate_id, :youtube_profile_id], unique: true, name: 'affiliate_id_youtube_profile_id'
  end
end
