class AddPublishDateFieldsToFeaturedCollections < ActiveRecord::Migration
  def self.up
    add_column :featured_collections, :publish_start_on, :date
    add_column :featured_collections, :publish_end_on, :date
  end

  def self.down
    remove_column :featured_collections, :publish_end_on
    remove_column :featured_collections, :publish_start_on
  end
end
