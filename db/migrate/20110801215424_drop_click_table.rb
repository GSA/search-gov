class DropClickTable < ActiveRecord::Migration
  def self.up
    drop_table :clicks
  end

  def self.down
  end
end
