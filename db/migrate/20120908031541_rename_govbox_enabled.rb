class RenameGovboxEnabled < ActiveRecord::Migration
  def change
    rename_column :forms, :govbox_enabled, :verified
  end
end
