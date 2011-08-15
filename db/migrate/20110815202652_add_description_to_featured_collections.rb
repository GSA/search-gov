class AddDescriptionToFeaturedCollections < ActiveRecord::Migration
  def self.up
    add_column :featured_collections, :description, :string
  end

  def self.down
    remove_column :featured_collections, :description
  end
end
