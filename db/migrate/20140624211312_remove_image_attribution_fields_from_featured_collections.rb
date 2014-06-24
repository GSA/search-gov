class RemoveImageAttributionFieldsFromFeaturedCollections < ActiveRecord::Migration
  def up
    remove_column :featured_collections, :image_attribution_url
    remove_column :featured_collections, :image_attribution
  end

  def down
    add_column :featured_collections, :image_attribution, :string
    add_column :featured_collections, :image_attribution_url, :string
  end
end
