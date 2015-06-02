class DropDailyUsageStat < ActiveRecord::Migration
  def up
    drop_table :daily_usage_stats
  end

  def down
  end
end
