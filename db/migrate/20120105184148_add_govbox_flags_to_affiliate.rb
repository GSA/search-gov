class AddGovboxFlagsToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_agency_govbox_enabled, :boolean, :default => false
    add_column :affiliates, :is_medline_govbox_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :affiliates, :is_medline_govbox_enabled
    remove_column :affiliates, :is_agency_govbox_enabled
  end
end
