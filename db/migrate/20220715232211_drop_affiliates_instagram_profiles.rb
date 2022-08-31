class DropAffiliatesInstagramProfiles < ActiveRecord::Migration[6.1]
  def change
    drop_table :affiliates_instagram_profiles do |t|
      t.integer "affiliate_id", null: false
      t.bigint "instagram_profile_id", null: false
      t.index ["affiliate_id", "instagram_profile_id"], name: "index_affiliates_instagram_profiles", unique: true
    end
  end
end
