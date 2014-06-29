class DropQueriesClicksStats < ActiveRecord::Migration
  def up
    drop_table :queries_clicks_stats
  end

  def down
    create_table "queries_clicks_stats", :force => true do |t|
      t.string  "affiliate", :limit => 33,   :null => false
      t.string  "query",                     :null => false
      t.date    "day",                       :null => false
      t.string  "url",       :limit => 2000, :null => false
      t.integer "times",                     :null => false
    end

    add_index "queries_clicks_stats", ["affiliate", "day"], :name => "index_queries_clicks_stats_on_affiliate_and_day"
    add_index "queries_clicks_stats", ["affiliate", "query", "day"], :name => "aqd"
    add_index "queries_clicks_stats", ["affiliate", "url", "day"], :name => "aud", :length => {"affiliate"=>nil, "url"=>255, "day"=>nil}
  end
end
