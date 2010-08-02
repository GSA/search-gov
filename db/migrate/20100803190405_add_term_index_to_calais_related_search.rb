class AddTermIndexToCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    add_index :calais_related_searches, :term, :unique => true
  end

  def self.down
    remove_index :calais_related_searches, :term
  end
end
