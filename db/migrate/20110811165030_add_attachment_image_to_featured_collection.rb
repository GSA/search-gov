class AddAttachmentImageToFeaturedCollection < ActiveRecord::Migration
  def self.up
    add_column :featured_collections, :image_file_name, :string
    add_column :featured_collections, :image_content_type, :string
    add_column :featured_collections, :image_file_size, :integer
    add_column :featured_collections, :image_updated_at, :datetime
    add_column :featured_collections, :image_alt_text, :string
    add_column :featured_collections, :image_attribution, :string
    add_column :featured_collections, :image_attribution_url, :string
  end

  def self.down
    remove_column :featured_collections, :image_file_name
    remove_column :featured_collections, :image_content_type
    remove_column :featured_collections, :image_file_size
    remove_column :featured_collections, :image_updated_at
    remove_column :featured_collections, :image_alt_text
    remove_column :featured_collections, :image_attribution
    remove_column :featured_collections, :image_attribution_url
  end
end
