class AddQueryIndexToDailyQueryStats < ActiveRecord::Migration
  def self.up
    add_index :daily_query_stats, [:query, :day]
  end

  def self.down
    remove_index :daily_query_stats, [:query, :day]
  end
end
