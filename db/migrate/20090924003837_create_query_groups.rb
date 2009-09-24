class CreateQueryGroups < ActiveRecord::Migration
  def self.up
    create_table :query_groups do |t|
      t.string :name, :null => false
      t.timestamps
    end
    add_index :query_groups, :name, :unique => true    
  end

  def self.down
    drop_table :query_groups
  end
end
