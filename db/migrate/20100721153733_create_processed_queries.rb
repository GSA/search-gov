class CreateProcessedQueries < ActiveRecord::Migration
  def self.up
    create_table :processed_queries do |t|
      t.string :query
      t.string :affiliate
      t.date :day
      t.integer :times

      t.timestamps
    end
  end

  def self.down
    drop_table :processed_queries
  end
end