class DropDailyQueryNoResultsStats < ActiveRecord::Migration
  def up
    drop_table :daily_query_noresults_stats
  end

  def down
    create_table "daily_query_noresults_stats", :force => true do |t|
      t.date    "day",       :null => false
      t.string  "affiliate", :null => false
      t.string  "query",     :null => false
      t.integer "times",     :null => false
    end

    add_index "daily_query_noresults_stats", ["affiliate", "day"], :name => "index_daily_query_noresults_stats_on_affiliate_and_day"
  end
end
