class RenamePdfDocumentsToIndexedDocuments < ActiveRecord::Migration
  def self.up
    rename_table :pdf_documents, :indexed_documents
    change_column :indexed_documents, :body, :longtext
  end

  def self.down
    rename_table :indexed_documents, :pdf_documents
    change_column :pdf_documents, :body, :text
  end
end
