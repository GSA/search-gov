class RemoveUniquenessFromMovingQueriesIndex < ActiveRecord::Migration
  def self.up
    remove_index :moving_queries, [:day, :window_size, :times]
    add_index :moving_queries, [:day, :window_size, :times]
  end

  def self.down
    remove_index :moving_queries, [:day, :window_size, :times]
    add_index :moving_queries, [:day, :window_size, :times], :unique => true
  end
end
