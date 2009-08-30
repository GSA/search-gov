class TrimQueryLength < ActiveRecord::Migration
  def self.up
    change_column(:daily_query_stats, :query, :string, :limit => 100)
    change_column(:daily_query_ip_stats, :query, :string, :limit => 100)
    change_column(:daily_query_ip_stats, :ipaddr, :string, :limit => 100)
  end

  def self.down
    change_column(:daily_query_ip_stats, :query, :string, :limit => 255)
    change_column(:daily_query_ip_stats, :ipaddr, :string, :limit => 255)
    change_column(:daily_query_stats, :query, :string, :limit => 255)
  end
end
