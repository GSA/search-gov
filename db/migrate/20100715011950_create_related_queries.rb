class CreateRelatedQueries < ActiveRecord::Migration
  def self.up
    create_table :related_queries do |t|
      t.string :query
      t.string :related_query
      t.float :score

      t.timestamps
    end
    add_index :related_queries, :query, :unique => false
  end

  def self.down
    drop_table :related_queries
  end
end
