class AddIsNavigableToDocumentCollections < ActiveRecord::Migration
  def self.up
    add_column :document_collections, :is_navigable, :boolean, :default => false
    update "UPDATE document_collections SET is_navigable = 1"
  end

  def self.down
    remove_column :document_collections, :is_navigable
  end
end
