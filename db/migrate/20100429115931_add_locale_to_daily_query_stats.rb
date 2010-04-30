class AddLocaleToDailyQueryStats < ActiveRecord::Migration
  def self.up
    add_column :daily_query_stats, :locale, :string, :limit => 5, :default => 'en'
    remove_index :daily_query_stats, [:day, :query, :affiliate]
    add_index :daily_query_stats, [:day, :query, :affiliate, :locale], :name => 'daily_query_stats_unique_index', :unique => true
    
    add_column :daily_query_ip_stats, :locale, :string, :limit => 5, :default => 'en'
  end

  def self.down
    remove_index :daily_query_stats, :name => 'daily_query_stats_unique_index'
    add_index :daily_query_stats, [:day, :query, :affiliate], :unique => true
    remove_column :daily_query_stats, :locale
    
    remove_column :daily_query_ip_stats, :locale
  end
end
