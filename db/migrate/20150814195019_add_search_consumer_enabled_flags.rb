class AddSearchConsumerEnabledFlags < ActiveRecord::Migration
  def change
    add_column :affiliates, :search_consumer_search_enabled, :boolean, default: false, null: false
    add_column :affiliates, :search_consumer_admin_enabled, :boolean, default: false, null: false
  end
end
