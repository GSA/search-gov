class AddIsOdieGovboxEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_odie_govbox_enabled, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :affiliates, :is_odie_govbox_enabled
  end
end
