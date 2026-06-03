class DropWatchers < ActiveRecord::Migration[7.1]
  def change
    drop_table :watchers, id: :integer do |t|
      t.string "type"
      t.integer "user_id"
      t.integer "affiliate_id"
      t.string "name"
      t.string "check_interval"
      t.string "throttle_period"
      t.string "unsafe_conditions"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "time_window"
      t.string "query_blocklist"
      t.json "conditions"
    end
  end
end
