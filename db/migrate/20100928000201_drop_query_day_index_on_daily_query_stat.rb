class DropQueryDayIndexOnDailyQueryStat < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_stats, :name => 'index_daily_query_stats_on_query_and_day'
  end

  def self.down
    add_index :daily_query_stats, [:query, :day], :name => 'index_daily_query_stats_on_query_and_day'  
  end
end
