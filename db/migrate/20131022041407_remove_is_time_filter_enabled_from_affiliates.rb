class RemoveIsTimeFilterEnabledFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :is_time_filter_enabled
  end

  def down
    add_column :affiliates, :is_time_filter_enabled, :boolean, default: true
  end
end
