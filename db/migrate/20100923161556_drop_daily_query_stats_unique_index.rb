class DropDailyQueryStatsUniqueIndex < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_stats, :name => 'daily_query_stats_unique_index'
  end

  def self.down
    add_index :daily_query_stats, [:day, :query, :affiliate, :locale], :name => 'daily_query_stats_unique_index', :unique => true  
  end
end
