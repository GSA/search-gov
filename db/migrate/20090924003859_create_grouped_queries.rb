class CreateGroupedQueries < ActiveRecord::Migration
  def self.up
    create_table :grouped_queries do |t|
      t.string :query, :null => false
      t.timestamps
    end
    add_index :grouped_queries, :query, :unique => true        
  end

  def self.down
    drop_table :grouped_queries
  end
end
