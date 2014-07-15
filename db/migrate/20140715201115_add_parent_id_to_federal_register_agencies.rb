class AddParentIdToFederalRegisterAgencies < ActiveRecord::Migration
  def change
    add_column :federal_register_agencies, :parent_id, :integer
  end
end
