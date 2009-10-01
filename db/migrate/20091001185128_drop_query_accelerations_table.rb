class DropQueryAccelerationsTable < ActiveRecord::Migration
  def self.up
    drop_table :query_accelerations
    drop_table :temp_window_counts
  end

  def self.down
  end
end
