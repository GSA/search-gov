class RemoveIsAgencyGovboxEnabled < ActiveRecord::Migration
  def up
    remove_column :affiliates, :is_agency_govbox_enabled
  end

  def down
    add_column :affiliates, :is_agency_govbox_enabled, :boolean, :default => false
  end
end
