class AddSitelinkGeneratorNamesToDocumentCollections < ActiveRecord::Migration
  def change
    add_column :document_collections, :sitelink_generator_names, :string
  end
end
