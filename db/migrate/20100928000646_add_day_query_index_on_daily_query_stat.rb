class AddDayQueryIndexOnDailyQueryStat < ActiveRecord::Migration
  def self.up
    add_index :daily_query_stats, [:day, :query], :name => 'dq'
  end

  def self.down
    remove_index :daily_query_stats, :name => 'dq'
  end
end
