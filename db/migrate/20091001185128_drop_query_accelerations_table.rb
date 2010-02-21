class DropQueryAccelerationsTable < ActiveRecord::Migration
  def self.up
    drop_table :query_accelerations
    # bk - No previous add_table migration found, commenting out
    # drop_table :temp_window_counts
  end

  def self.down
  end
end
