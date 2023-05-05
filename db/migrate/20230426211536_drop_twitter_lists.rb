class DropTwitterLists < ActiveRecord::Migration[7.0]
  def change
    drop_table :twitter_lists, id: false do |t|
      t.bigint "id", null: false, unsigned: true
      t.text "member_ids", size: :long
      t.bigint "last_status_id", default: 1, null: false, unsigned: true
      t.string "statuses_updated_at"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.json "safe_member_ids"
      t.index ["id"], name: "index_twitter_lists_on_id", unique: true
    end
  end
end
