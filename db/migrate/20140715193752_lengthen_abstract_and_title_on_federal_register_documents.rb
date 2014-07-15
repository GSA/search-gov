class LengthenAbstractAndTitleOnFederalRegisterDocuments < ActiveRecord::Migration
  def up
    change_column :federal_register_documents, :title, :text, null: false
    change_column :federal_register_documents, :abstract, :text
  end

  def down
    change_column :federal_register_documents, :title, :string, null: false
    change_column_default :federal_register_documents, :title, nil
    change_column :federal_register_documents, :abstract, :string
  end
end
