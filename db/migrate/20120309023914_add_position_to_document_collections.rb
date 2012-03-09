class AddPositionToDocumentCollections < ActiveRecord::Migration
  def self.up
    add_column :document_collections, :position, :integer
  end

  def self.down
    remove_column :document_collections, :position
  end
end
