class AddScopeKeywordsToDocumentCollections < ActiveRecord::Migration
  def change
    add_column :document_collections, :scope_keywords, :string
  end
end
