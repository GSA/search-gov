class AddGovboxEnabledToForms < ActiveRecord::Migration
  def change
    add_column :forms, :govbox_enabled, :boolean, :null => false, :default => true
  end
end
