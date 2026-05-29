class DropExcludedUrls < ActiveRecord::Migration[7.1]
  def change
    drop_table :excluded_urls, id: :integer do |t|
      t.integer "affiliate_id", null: false
      t.string "url", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["affiliate_id"], name: "index_excluded_urls_on_affiliate_id"
    end
  end
end
