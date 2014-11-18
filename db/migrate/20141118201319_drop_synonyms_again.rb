class DropSynonymsAgain < ActiveRecord::Migration
  def up
    drop_table :synonyms
  end

  def down
    create_table "synonyms", :force => true do |t|
      t.string   "entry",                                 :null => false
      t.text     "notes"
      t.string   "status",       :default => "Candidate", :null => false
      t.string   "locale",                                :null => false
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.integer  "affiliate_id"
    end

    add_index "synonyms", ["entry", "locale"], :name => "index_synonyms_on_entry_and_locale", :unique => true

  end
end
