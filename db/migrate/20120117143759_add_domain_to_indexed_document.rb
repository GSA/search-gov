class AddDomainToIndexedDocument < ActiveRecord::Migration
  def self.up
    add_column :indexed_documents, :indexed_domain_id, :integer
    add_index :indexed_documents, :indexed_domain_id
  end

  def self.down
    remove_index :indexed_documents, :indexed_domain_id
    remove_column :indexed_documents, :indexed_domain_id
  end
end
