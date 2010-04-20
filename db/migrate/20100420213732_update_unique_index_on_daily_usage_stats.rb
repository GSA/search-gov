class UpdateUniqueIndexOnDailyUsageStats < ActiveRecord::Migration
  def self.up
    remove_index :daily_usage_stats, [:day, :profile]
    add_index :daily_usage_stats, [:day, :profile, :affiliate], :unique => true
  end

  def self.down
    remove_index :daily_usage_stats, [:day, :profile, :affiliate]
    add_index :daily_usage_stats, [:day, :profile], :unique => true
  end
end
