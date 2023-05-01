class DropTwitterListsTwitterProfiles < ActiveRecord::Migration[7.0]
  def change
    drop_table :twitter_lists_twitter_profiles, id: false do |t|
      t.bigint "twitter_list_id", null: false, unsigned: true
      t.integer "twitter_profile_id", null: false
      t.index ["twitter_list_id", "twitter_profile_id"], name: "twitter_list_id_profile_id", unique: true
      t.index ["twitter_profile_id"], name: "index_twitter_lists_twitter_profiles_on_twitter_profile_id"
    end
  end
end
