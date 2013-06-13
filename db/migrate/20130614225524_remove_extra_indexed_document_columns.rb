class RemoveExtraIndexedDocumentColumns < ActiveRecord::Migration
  def up
    remove_columns :indexed_documents, :content_hash, :indexed_domain_id
  end

  def down
    add_column :indexed_documents, :indexed_domain_id, :integer
    add_column :indexed_documents, :content_hash, :string, :limit => 32
  end
end
