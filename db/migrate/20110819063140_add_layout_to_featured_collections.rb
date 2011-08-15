class AddLayoutToFeaturedCollections < ActiveRecord::Migration
  def self.up
    add_column :featured_collections, :layout, :string, :null => false
  end

  def self.down
    remove_column :featured_collections, :layout
  end
end
