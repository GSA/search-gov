class TrimIpaddrLength < ActiveRecord::Migration
  def self.up
    change_column(:daily_query_ip_stats, :ipaddr, :string, :limit => 17)  
  end

  def self.down
    change_column(:daily_query_ip_stats, :ipaddr, :string, :limit => 100)
  end
end
