class AddAttachmentPageBackgroundImageStagedPageBackgroundImageToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :page_background_image_file_name, :string
    add_column :affiliates, :page_background_image_content_type, :string
    add_column :affiliates, :page_background_image_file_size, :integer
    add_column :affiliates, :page_background_image_updated_at, :datetime
    add_column :affiliates, :staged_page_background_image_file_name, :string
    add_column :affiliates, :staged_page_background_image_content_type, :string
    add_column :affiliates, :staged_page_background_image_file_size, :integer
    add_column :affiliates, :staged_page_background_image_updated_at, :datetime
  end

  def self.down
    remove_column :affiliates, :page_background_image_file_name
    remove_column :affiliates, :page_background_image_content_type
    remove_column :affiliates, :page_background_image_file_size
    remove_column :affiliates, :page_background_image_updated_at
    remove_column :affiliates, :staged_page_background_image_file_name
    remove_column :affiliates, :staged_page_background_image_content_type
    remove_column :affiliates, :staged_page_background_image_file_size
    remove_column :affiliates, :staged_page_background_image_updated_at
  end
end
