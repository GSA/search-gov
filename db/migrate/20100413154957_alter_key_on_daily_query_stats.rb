class AlterKeyOnDailyQueryStats < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_stats, [:day, :query]
    add_index :daily_query_stats, [:day, :query, :affiliate], :unique => true
  end

  def self.down
    remove_index :daily_query_stats, [:day, :query, :affiliate]
    add_index :daily_query_stats, [:day, :query], :unique => true
  end
end
