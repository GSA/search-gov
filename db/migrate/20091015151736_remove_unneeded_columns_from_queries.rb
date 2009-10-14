class RemoveUnneededColumnsFromQueries < ActiveRecord::Migration
  def self.up
    remove_column :queries, :epoch
    remove_column :queries, :wday
    remove_column :queries, :month
    remove_column :queries, :time_col
    remove_column :queries, :day
    remove_column :queries, :tz
    remove_column :queries, :year
  end

  def self.down
  end
end
