class DropDailySearchModuleStat < ActiveRecord::Migration
  def up
    drop_table :daily_search_module_stats
  end

  def down
  end
end
