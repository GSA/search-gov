class DropRecalls < ActiveRecord::Migration
  def up
    drop_table :auto_recalls
    drop_table :food_recalls
    drop_table :recall_details
    drop_table :recalls
  end

  def down
    create_table "recalls", :force => true do |t|
      t.string   "recall_number", :limit => 10
      t.integer  "y2k"
      t.date     "recalled_on"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "organization",  :limit => 10
    end

    add_index "recalls", ["recall_number"], :name => "index_recalls_on_recall_number"

    create_table "recall_details", :force => true do |t|
      t.integer  "recall_id"
      t.string   "detail_type"
      t.string   "detail_value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "recall_details", ["recall_id"], :name => "index_recall_details_on_recall_id"

    create_table "food_recalls", :force => true do |t|
      t.integer  "recall_id"
      t.string   "summary",                   :null => false
      t.text     "description",               :null => false
      t.string   "url",                       :null => false
      t.string   "food_type",   :limit => 10
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "food_recalls", ["recall_id"], :name => "index_food_recalls_on_recall_id"

    create_table "auto_recalls", :force => true do |t|
      t.integer  "recall_id"
      t.string   "make",                     :limit => 25
      t.string   "model"
      t.integer  "year"
      t.string   "component_description"
      t.date     "manufacturing_begin_date"
      t.date     "manufacturing_end_date"
      t.string   "manufacturer",             :limit => 40
      t.string   "recalled_component_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "auto_recalls", ["recall_id"], :name => "index_auto_recalls_on_recall_id"
  end
end
