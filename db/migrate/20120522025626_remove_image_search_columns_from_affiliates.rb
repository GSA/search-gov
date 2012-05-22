class RemoveImageSearchColumnsFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :is_image_search_enabled
    remove_column :affiliates, :old_image_search_label
  end

  def self.down
    add_column :affiliates, :is_image_search_enabled, :boolean, :default => true
    add_column :affiliates, :old_image_search_label, :string, :limit => 20
  end
end
