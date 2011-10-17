class ReduceIndexOnDqs < ActiveRecord::Migration
  def self.up
    remove_index :daily_query_stats, :name => 'adl'
    add_index :daily_query_stats, [:affiliate, :day], :name => 'ad'
  end

  def self.down
    remove_index :daily_query_stats, :name => 'ad'
    add_index :daily_query_stats, [:affiliate, :day, :locale], :name => 'adl'
  end

end
