class AddIndexToDailyQueryIpStats < ActiveRecord::Migration
  def self.up
    add_index :daily_query_ip_stats, [:day, :affiliate, :locale], :name => 'daily_query_ip_stats_index'
  end

  def self.down
    remove_index :daily_query_stats, :name => 'daily_query_ip_stats_index'
  end
end
