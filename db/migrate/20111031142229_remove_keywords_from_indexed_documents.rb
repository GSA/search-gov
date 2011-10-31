class RemoveKeywordsFromIndexedDocuments < ActiveRecord::Migration
  def self.up
    remove_column :indexed_documents, :keywords
  end

  def self.down
    add_column :indexed_documents, :keywords, :string
  end
end
