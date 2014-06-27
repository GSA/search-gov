class AddFederalRegisterAgencyIdToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :federal_register_agency_id, :integer
  end
end
