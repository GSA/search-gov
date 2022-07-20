class RemoveAdvancedSearchEnabledFromDocumentCollections < ActiveRecord::Migration[6.1]
  def change
    remove_column :document_collections, :advanced_search_enabled, :boolean
  end
end
