class DropTwitterProfiles < ActiveRecord::Migration[7.0]
  def change
    drop_table :twitter_profiles, id: :integer do |t|
      t.bigint "twitter_id", null: false, unsigned: true
      t.string "screen_name"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.string "profile_image_url", null: false
      t.string "name", null: false
      t.index ["twitter_id"], name: "index_twitter_profiles_on_twitter_id", unique: true
    end
  end
end
