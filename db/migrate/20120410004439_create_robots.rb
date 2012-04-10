class CreateRobots < ActiveRecord::Migration
  def self.up
    create_table :robots do |t|
      t.string :domain, :null => false, :unique => true
      t.text :prefixes
      t.timestamps
    end
    add_index :robots, :domain
  end

  def self.down
    drop_table :robots
  end
end
