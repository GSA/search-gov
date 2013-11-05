class RemoveLocaleFromFeaturedCollections < ActiveRecord::Migration
  def up
    remove_column :featured_collections, :locale
  end

  def down
    add_column :featured_collections, :locale, :string, null: false
  end
end
