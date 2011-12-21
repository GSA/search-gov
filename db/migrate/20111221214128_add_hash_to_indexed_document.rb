class AddHashToIndexedDocument < ActiveRecord::Migration
  def self.up
    add_column :indexed_documents, :content_hash, "char(32)"
    add_index :indexed_documents, [:affiliate_id, :content_hash], :unique => true
  end

  def self.down
    remove_index :indexed_documents, [:affiliate_id, :content_hash]
    remove_column :indexed_documents, :content_hash
  end
end
