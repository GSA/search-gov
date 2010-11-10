class AlterIndexOnCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    remove_index :calais_related_searches, [:term, :locale]
    add_index :calais_related_searches, [:affiliate_id, :term]
  end

  def self.down
    remove_index :calais_related_searches, [:affiliate_id, :term]
    add_index :calais_related_searches, [:term, :locale]
  end
end
