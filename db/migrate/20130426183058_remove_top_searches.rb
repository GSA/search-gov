class RemoveTopSearches < ActiveRecord::Migration
  def self.changes
    drop_table :top_searches
  end
end
