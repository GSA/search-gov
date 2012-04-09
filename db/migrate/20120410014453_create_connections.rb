class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :affiliate_id, :null => false
      t.integer :connected_affiliate_id, :null => false
      t.string :label, :limit => 50, :null => false
      t.integer :position, :default => 100, :null => false

      t.timestamps
    end
    add_index :connections, :affiliate_id
  end

  def self.down
    drop_table :connections
  end
end
