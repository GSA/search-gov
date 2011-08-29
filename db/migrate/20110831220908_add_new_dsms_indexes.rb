class AddNewDsmsIndexes < ActiveRecord::Migration
  def self.up
    add_index :daily_search_module_stats, [:module_tag, :day]
  end

  def self.down
    remove_index :daily_search_module_stats, [:module_tag, :day]
  end
end
