class RemoveSitelinkGeneratorNames < ActiveRecord::Migration[6.0]
  def change
    remove_column :document_collections, :sitelink_generator_names, :string
  end
end
