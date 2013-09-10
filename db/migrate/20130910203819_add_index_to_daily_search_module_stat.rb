class AddIndexToDailySearchModuleStat < ActiveRecord::Migration
  def change
    add_index :daily_search_module_stats, [:affiliate_name, :day]
  end
end
