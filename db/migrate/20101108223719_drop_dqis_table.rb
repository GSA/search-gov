class DropDqisTable < ActiveRecord::Migration
  def self.up
    drop_table :daily_query_ip_stats
  end

  def self.down
  end
end
