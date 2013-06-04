class DropLegacyYoutubeProfiles < ActiveRecord::Migration
  def up
    drop_table :legacy_youtube_profiles
  end

  def down
    create_table "legacy_youtube_profiles", :force => true do |t|
      t.string   "username"
      t.integer  "affiliate_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "legacy_youtube_profiles", ["affiliate_id"], :name => "index_youtube_profiles_on_affiliate_id"
  end
end
