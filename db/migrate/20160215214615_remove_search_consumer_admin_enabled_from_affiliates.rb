class RemoveSearchConsumerAdminEnabledFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :search_consumer_admin_enabled
  end

  def down
    add_column :affiliates, :search_consumer_admin_enabled, :boolean, default: false, null: false
  end
end
