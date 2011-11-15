class AddIndexToIndexedDocumentUrls < ActiveRecord::Migration
  def self.up
    add_index :indexed_documents, [:url, :affiliate_id], :unique => true
  end

  def self.down
    remove_index :indexed_documents, [:url, :affiliate_id]
  end
end
