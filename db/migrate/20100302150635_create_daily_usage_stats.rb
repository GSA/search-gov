class CreateDailyUsageStats < ActiveRecord::Migration
  def self.up
    create_table :daily_usage_stats do |t|
      t.date :day
      t.string :profile
      t.integer :total_queries
      t.integer :total_page_views
      t.integer :total_unique_visitors
      t.integer :total_clicks

      t.timestamps
    end
    add_index :daily_usage_stats, [:day, :profile], :unique => true
  end

  def self.down
    drop_table :daily_usage_stats
  end
end
