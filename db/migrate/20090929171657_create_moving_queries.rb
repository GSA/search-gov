class CreateMovingQueries < ActiveRecord::Migration
  def self.up
    create_table :moving_queries do |t|
      t.date :day, :null => false
      t.integer :window_size, :null => false
      t.integer :times, :null => false
      t.string :query, :null => false, :limit => 100
      t.float :mean, :null => false
      t.float :std_dev, :null => false
    end
    add_index :moving_queries, [:day, :window_size, :times], :unique => true
  end

  def self.down
    drop_table :moving_queries
  end
end
