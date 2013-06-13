class RemoveIndexedDomainReferences < ActiveRecord::Migration
  def up
    remove_index :indexed_documents, :indexed_domain_id
    remove_index :indexed_documents, [:affiliate_id, :content_hash]
  end

  def down
    add_index "indexed_documents", ["indexed_domain_id"], :name => "index_indexed_documents_on_indexed_domain_id"
    add_index "indexed_documents", ["affiliate_id", "content_hash"], :name => "index_indexed_documents_on_affiliate_id_and_content_hash", :unique => true
  end
end
