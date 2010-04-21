class RemoveIndexesFromClick < ActiveRecord::Migration
  def self.up
    remove_index :clicks, :affiliate
    remove_index :clicks, :queried_at
    remove_index :clicks, :serp_position
  end

  def self.down
    add_index :clicks, :serp_position
    add_index :clicks, :queried_at
    add_index :clicks, :affiliate
  end
end
