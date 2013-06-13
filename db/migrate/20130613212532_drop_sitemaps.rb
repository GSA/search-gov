class DropSitemaps < ActiveRecord::Migration
  def up
    drop_table :sitemaps
  end

  def down
    create_table "sitemaps", :force => true do |t|
      t.string "url"
      t.integer "affiliate_id"
      t.datetime "last_crawled_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sitemaps", ["affiliate_id"], :name => "index_sitemaps_on_affiliate_id"
  end
end
