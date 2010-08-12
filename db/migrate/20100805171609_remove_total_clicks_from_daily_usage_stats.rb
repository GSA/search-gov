class RemoveTotalClicksFromDailyUsageStats < ActiveRecord::Migration
  def self.up
    remove_column :daily_usage_stats, :total_clicks
  end

  def self.down
    add_column :daily_usage_stats, :total_clicks, :integer
  end
end
