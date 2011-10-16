class RedoIndexesOnDqs < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_stats, :name=>"aldq"
    remove_index :daily_query_stats, :name => 'qdal'
    remove_index :daily_query_stats, :name => 'dq'
    add_index :daily_query_stats, [:affiliate, :day], :name => 'ad'
    add_index :daily_query_stats, [:day, :affiliate], :name => 'da'
    add_index :daily_query_stats, [:query, :day], :name => 'qd'
  end

  def self.down
    add_index :daily_query_stats, [:affiliate, :locale, :day, :query], :unique=> true, :name=>"aldq"
    add_index :daily_query_stats, [:query, :day, :affiliate, :locale], :name => 'qdal', :unique => true
    add_index :daily_query_stats, [:day, :query], :name => 'dq'
    remove_index :daily_query_stats, :name => 'ad'
    remove_index :daily_query_stats, :name => 'da'
    remove_index :daily_query_stats, :name => 'qd'
  end
end
