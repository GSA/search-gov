class AddIsFederalRegisterDocumentGovboxEnabledToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :is_federal_register_document_govbox_enabled, :boolean, default: false, null: false
  end
end
