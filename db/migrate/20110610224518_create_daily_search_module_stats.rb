class CreateDailySearchModuleStats < ActiveRecord::Migration
  def self.up
    create_table :daily_search_module_stats do |t|
      t.date :day, :null => false
      t.string :affiliate_name, :null => false
      t.string :module_tag, :null => false
      t.string :vertical, :null => false
      t.string :locale, :null => false
      t.integer :impressions, :null => false
      t.integer :clicks, :null => false
    end

    add_index :daily_search_module_stats, [:day, :affiliate_name, :module_tag, :vertical, :locale], :unique => true, :name => "dics_unique"
    add_index :daily_search_module_stats, [:day, :module_tag], :name => "day_module"
  end

  def self.down
    drop_table :daily_search_module_stats
  end
end
