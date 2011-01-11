class RemoveLocations < ActiveRecord::Migration
  def self.up
    drop_table :locations
  end

  def self.down
    create_table "locations", :force => true do |t|
      t.integer  "zip_code"
      t.string   "state"
      t.string   "city"
      t.integer  "population"
      t.float    "lat"
      t.float    "lng"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "locations", ["city"], :name => "index_locations_on_city"
    add_index "locations", ["state"], :name => "index_locations_on_state"
    add_index "locations", ["zip_code"], :name => "index_locations_on_zip_code"
  end
end
