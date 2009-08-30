class CreateQueryAccelerations < ActiveRecord::Migration
  def self.up
    create_table :query_accelerations do |t|
      t.date :day, :null => false
      t.integer :window_size, :null => false
      t.string :query, :null => false, :limit => 100
      t.float :score, :null => false
    end
    add_index :query_accelerations, [:day, :window_size, :score]
  end

  def self.down
    drop_table :query_accelerations
  end
end
