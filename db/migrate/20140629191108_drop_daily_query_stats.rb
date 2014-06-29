class DropDailyQueryStats < ActiveRecord::Migration
  def up
    drop_table :daily_query_stats
  end

  def down
    create_table "daily_query_stats", :force => true do |t|
      t.date    "day",                                            :null => false
      t.string  "query",     :limit => 100,                       :null => false
      t.integer "times",                                          :null => false
      t.string  "affiliate", :limit => 33,  :default => "usagov"
      t.string  "locale",    :limit => 5,   :default => "en"
    end

    add_index "daily_query_stats", ["affiliate", "day"], :name => "ad"
    add_index "daily_query_stats", ["day", "affiliate"], :name => "da"
    add_index "daily_query_stats", ["query", "day"], :name => "qd"
  end
end
