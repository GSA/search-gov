class DropCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    drop_table :calais_related_searches
  end

  def self.down
    create_table "calais_related_searches", :force => true do |t|
      t.string   "term"
      t.string   "related_terms",  :limit => 4096
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "locale",                         :default => "en",  :null => false
      t.integer  "affiliate_id"
      t.boolean  "gets_refreshed",                 :default => false, :null => false
    end

    add_index "calais_related_searches", ["affiliate_id", "term"], :name => "index_calais_related_searches_on_affiliate_id_and_term"
  end
end
