class UpdateIndexOnCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    remove_index :calais_related_searches, :term
    add_index :calais_related_searches, [:term, :locale], :unique => true
  end

  def self.down
    remove_index :calais_related_searches, [:term, :locale]
    add_index :calais_related_searches, :term, :unique => true
  end
end
