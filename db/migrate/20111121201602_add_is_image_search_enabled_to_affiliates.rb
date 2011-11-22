class AddIsImageSearchEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_image_search_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :affiliates, :is_image_search_enabled
  end
end
