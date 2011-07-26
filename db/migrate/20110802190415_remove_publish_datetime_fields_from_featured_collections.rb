class RemovePublishDatetimeFieldsFromFeaturedCollections < ActiveRecord::Migration
  def self.up
    remove_column :featured_collections, :publish_start_at
    remove_column :featured_collections, :publish_end_at
  end

  def self.down
    add_column :featured_collections, :publish_start_at, :datetime
    add_column :featured_collections, :publish_end_at, :datetime
  end
end
