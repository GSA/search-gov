class AddRawLogAccessToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :raw_log_access_enabled, :boolean, :null => false, :default => false
  end
end
