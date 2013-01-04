class AddAgencyIdToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :agency_id, :integer
  end
end
