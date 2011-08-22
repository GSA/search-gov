class RemoveDescriptionFromFeaturedCollections < ActiveRecord::Migration
  def self.up
    remove_column :featured_collections, :description
  end

  def self.down
    add_column :featured_collections, :description, :string
  end
end
