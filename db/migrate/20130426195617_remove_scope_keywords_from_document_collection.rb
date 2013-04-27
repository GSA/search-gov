class RemoveScopeKeywordsFromDocumentCollection < ActiveRecord::Migration
  def change
    remove_column :document_collections, :scope_keywords
  end
end
