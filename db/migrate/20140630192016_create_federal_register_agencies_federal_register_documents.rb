class CreateFederalRegisterAgenciesFederalRegisterDocuments < ActiveRecord::Migration
  def change
    create_table :federal_register_agencies_federal_register_documents, id: false do |t|
      t.references :federal_register_agency, null: false
      t.references :federal_register_document, null: false
    end

    add_index :federal_register_agencies_federal_register_documents,
              [:federal_register_agency_id, :federal_register_document_id],
              unique: true,
              name: 'index_federal_register_agencies_federal_register_documents'
  end
end
