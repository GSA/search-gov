class AddAdvancedSearchEnabledToDocumentCollections < ActiveRecord::Migration
  def change
    add_column :document_collections, :advanced_search_enabled, :boolean, default: false, null: false
  end
end
