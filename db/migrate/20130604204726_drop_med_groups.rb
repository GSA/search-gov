class DropMedGroups < ActiveRecord::Migration
  def up
    drop_table :med_groups
  end

  def down
    create_table "med_groups", :force => true do |t|
      t.integer  "medline_gid"
      t.string   "medline_title",                                  :null => false
      t.string   "medline_url",   :limit => 120
      t.string   "locale",        :limit => 5,   :default => "en"
      t.boolean  "visible",                      :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "med_groups", ["medline_gid"], :name => "index_med_groups_on_medline_gid"
    add_index "med_groups", ["medline_title"], :name => "index_med_groups_on_medline_title"
  end
end
