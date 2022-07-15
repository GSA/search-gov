class DropAffiliatesInstagramProfiles < ActiveRecord::Migration[6.1]
  def change
    drop_table :affiliates_instagram_profiles
  end
end
