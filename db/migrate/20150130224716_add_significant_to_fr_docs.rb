class AddSignificantToFrDocs < ActiveRecord::Migration
  def change
    add_column :federal_register_documents, :significant, :boolean, null: false, default: false
  end
end
