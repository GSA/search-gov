class RemoveLayoutFromFeaturedCollections < ActiveRecord::Migration
  def up
    remove_column :featured_collections, :layout
  end

  def down
    add_column :featured_collections, :layout, :string, null: false
  end
end
