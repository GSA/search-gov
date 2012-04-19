class RemoveWebtrendsFromDailyUsageStats < ActiveRecord::Migration
  def self.up
    remove_index :daily_usage_stats, :name => 'apd'
    remove_index :daily_usage_stats, [:day, :profile, :affiliate]
    connection.execute("delete from daily_usage_stats where profile <> 'Affiliates'")
    remove_column :daily_usage_stats, :profile
    remove_column :daily_usage_stats, :total_page_views
    remove_column :daily_usage_stats, :total_unique_visitors
    remove_column :daily_usage_stats, :created_at
    remove_column :daily_usage_stats, :updated_at
    add_index :daily_usage_stats, [:affiliate, :day], :unique => true
    add_index :daily_usage_stats, [:day, :affiliate], :unique => true
  end

  def self.down
    remove_index :daily_usage_stats, [:day, :affiliate]
    remove_index :daily_usage_stats, [:affiliate, :day]
    add_column :daily_usage_stats, :profile, :string
    add_column :daily_usage_stats, :total_page_views, :integer
    add_column :daily_usage_stats, :total_unique_visitors, :integer
    add_column :daily_usage_stats, :created_at, :timestamp
    add_column :daily_usage_stats, :updated_at, :timestamp
    add_index :daily_usage_stats, [:affiliate, :profile, :day], :name => 'apd', :unique => true
    add_index :daily_usage_stats, [:day, :profile, :affiliate], :unique => true
  end
end
