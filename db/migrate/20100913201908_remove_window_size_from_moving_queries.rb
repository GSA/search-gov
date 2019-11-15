class RemoveWindowSizeFromMovingQueries < ActiveRecord::Migration
  def self.up
    MovingQuery.where('window_size').delete_all
    remove_index :moving_queries, [:day, :window_size, :times]
    remove_column :moving_queries, :window_size
    add_index :moving_queries, [:day, :times]
  end

  def self.down
    remove_index :moving_queries, [:day, :times]
    add_column :moving_queries, :window_size, :integer
    add_index :moving_queries, [:day, :window_size, :times]
  end
end
