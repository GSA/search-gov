class DropDsmsIndexes < ActiveRecord::Migration
  def self.up
    remove_index :daily_search_module_stats, :name => "dics_unique"
    remove_index :daily_search_module_stats, :name => "day_module"
  end

  def self.down
    add_index :daily_search_module_stats, [:day, :affiliate_name, :module_tag, :vertical, :locale], :unique => true, :name => "dics_unique"
    add_index :daily_search_module_stats, [:day, :module_tag], :name => "day_module"
  end
end
