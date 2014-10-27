class AddDocketIdToFederalRegisterDocuments < ActiveRecord::Migration
  def change
    add_column :federal_register_documents, :docket_id, :string
  end
end
