class DropLocaleFromDailyQueryNoresultsStats < ActiveRecord::Migration
  def self.up
    remove_column :daily_query_noresults_stats, :locale
  end

  def self.down
    add_column :daily_query_noresults_stats, :locale, :null => false
  end
end
