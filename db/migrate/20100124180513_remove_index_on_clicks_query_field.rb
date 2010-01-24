class RemoveIndexOnClicksQueryField < ActiveRecord::Migration
  def self.up
    remove_index :clicks, :query
  end

  def self.down
    add_index :clicks, :query, :unique => false
  end
end
