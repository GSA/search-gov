class ChangeIndexOnDailyQueryIpStats < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_ip_stats, [:day, :query, :ipaddr]
    add_index :daily_query_ip_stats, :query
  end

  def self.down
    remove_index :daily_query_ip_stats, :query
    add_index :daily_query_ip_stats, [:day, :query, :ipaddr], :unique => true
  end
end
