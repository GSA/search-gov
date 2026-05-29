class DropTagFilters < ActiveRecord::Migration[7.1]
  def change
    drop_table :tag_filters, id: :integer do |t|
    t.integer "affiliate_id", null: false
    t.string "tag"
    t.boolean "exclude"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id"], name: "index_tag_filters_on_affiliate_id"
    end
  end
end
