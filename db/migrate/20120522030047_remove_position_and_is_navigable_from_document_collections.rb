class RemovePositionAndIsNavigableFromDocumentCollections < ActiveRecord::Migration
  def self.up
    remove_column :document_collections, :position
    remove_column :document_collections, :is_navigable
  end

  def self.down
    add_column :document_collections, :position, :integer
    add_column :document_collections, :is_navigable, :boolean, :default => false
  end
end
