class DropQueriesTable < ActiveRecord::Migration
  def self.up
    drop_table :queries
  end

  def self.down
  end
end
