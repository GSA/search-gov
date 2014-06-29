class DropDailyClickStats < ActiveRecord::Migration
  def up
    drop_table :daily_click_stats
  end

  def down
    create_table "daily_click_stats", :force => true do |t|
      t.string  "affiliate", :limit => 33,   :null => false
      t.date    "day",                       :null => false
      t.string  "url",       :limit => 2000, :null => false
      t.integer "times",                     :null => false
    end

    add_index "daily_click_stats", ["affiliate", "day"], :name => "index_daily_click_stats_on_affiliate_and_day"
  end
end
