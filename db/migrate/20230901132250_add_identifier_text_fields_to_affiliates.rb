class AddIdentifierTextFieldsToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :identifier_domain_name, :string
    add_column :affiliates, :parent_agency_name, :string
    add_column :affiliates, :parent_agency_link, :string
  end
end
