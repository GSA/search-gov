class AddLastSuccessfulLoadDocumentsAtToFederalRegisterAgencies < ActiveRecord::Migration
  def change
    add_column :federal_register_agencies, :last_successful_load_documents_at, :datetime
  end
end
