class AddIndexToIndexedDocuments < ActiveRecord::Migration
  def self.up
    add_index :indexed_documents, [:affiliate_id, :id], :unique => true
  end

  def self.down
    remove_index :indexed_documents, [:affiliate_id, :id]
  end
end
