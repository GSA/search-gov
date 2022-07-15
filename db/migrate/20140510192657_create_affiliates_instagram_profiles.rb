class CreateAffiliatesInstagramProfiles < ActiveRecord::Migration
  def change
    create_table :affiliates_instagram_profiles, id: false do |t|
      t.references :affiliate, null: false
      t.references :instagram_profile, limit: 8, null: false
    end

    add_index :affiliates_instagram_profiles,
              [:affiliate_id, :instagram_profile_id],
              unique: true,
              name: 'index_affiliates_instagram_profiles'
  end
end
