class AddIsTimeFilterEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_time_filter_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :affiliates, :is_time_filter_enabled
  end
end
