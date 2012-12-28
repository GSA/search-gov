class AddOrgCodeToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :organization_code, :string
  end
end
