class RemoveParentAgencyNameAndParentAgencyLinkFromAffiliates < ActiveRecord::Migration[7.1]
  def change
    remove_column :affiliates, :parent_agency_name, :string
    remove_column :affiliates, :parent_agency_link, :string
  end
end
