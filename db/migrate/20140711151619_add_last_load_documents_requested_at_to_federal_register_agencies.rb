class AddLastLoadDocumentsRequestedAtToFederalRegisterAgencies < ActiveRecord::Migration
  def change
    add_column :federal_register_agencies, :last_load_documents_requested_at, :datetime
  end
end
