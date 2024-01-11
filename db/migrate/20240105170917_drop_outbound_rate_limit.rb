class DropOutboundRateLimit < ActiveRecord::Migration[7.0]
  def change
    drop_table :outbound_rate_limits, id: :integer do |t|
      t.string "name", null: false
      t.integer "limit", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "interval", limit: 10, default: "day"
      t.index ["name"], name: "index_outbound_rate_limits_on_name"
    end
  end
end
