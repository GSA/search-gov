class DropCommonSubstrings < ActiveRecord::Migration
  def up
    drop_table :common_substrings
  end

  def down
    create_table "common_substrings", :force => true do |t|
      t.integer  "indexed_domain_id",                  :null => false
      t.text     "substring",                          :null => false
      t.float    "saturation",        :default => 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "common_substrings", ["indexed_domain_id"], :name => "index_common_substrings_on_indexed_domain_id"
  end
end
