class DropAffiliateTwitterSettings < ActiveRecord::Migration[7.0]
  def change
    drop_table :affiliate_twitter_settings, id: :integer do |t|
      t.integer "affiliate_id", null: false
      t.integer "twitter_profile_id", null: false
      t.boolean "show_lists", default: false, null: false
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["affiliate_id", "twitter_profile_id"], name: "aff_id_tp_id"
      t.index ["twitter_profile_id"], name: "index_affiliate_twitter_settings_on_twitter_profile_id"
    end
  end
end
