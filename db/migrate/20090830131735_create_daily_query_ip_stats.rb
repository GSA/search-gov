class CreateDailyQueryIpStats < ActiveRecord::Migration
  def self.up
    create_table :daily_query_ip_stats do |t|
      t.date :day, :null => false
      t.string :query, :null => false, :length => 100
      t.string :ipaddr, :null => false, :length => 17
      t.integer :times, :null => false
    end
    add_index :daily_query_ip_stats, [:day, :query, :ipaddr], :unique => true
  end

  def self.down
    drop_table :daily_query_ip_stats
  end
end
