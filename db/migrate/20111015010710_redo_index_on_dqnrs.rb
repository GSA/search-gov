class RedoIndexOnDqnrs < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_noresults_stats, :name => "dalq"
    add_index :daily_query_noresults_stats, [:affiliate, :day]
  end

  def self.down
    add_index :daily_query_noresults_stats, [:day, :affiliate, :locale, :query], :unique => true, :name => "dalq"
    remove_index :daily_query_noresults_stats, [:affiliate, :day]
  end
end
