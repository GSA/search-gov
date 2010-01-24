class AddIndexOnClicksQueriedAtAndAffiliate < ActiveRecord::Migration
  def self.up
    add_index :clicks, :queried_at, :unique => false
    add_index :clicks, :affiliate, :unique => false
    add_index :clicks, :source, :unique => false
    add_index :clicks, :project, :unique => false
    add_index :clicks, :serp_position, :unique => false
    add_index :clicks, :query, :unique => false
  end

  def self.down
    remove_index :clicks, :queried_at
    remove_index :clicks, :affiliate
    remove_index :clicks, :source
    remove_index :clicks, :project
    remove_index :clicks, :serp_position
    remove_index :clicks, :query
  end
end
