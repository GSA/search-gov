class RemoveStagedAttachmentsFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :staged_header_image_file_name
    remove_column :affiliates, :staged_header_image_content_type
    remove_column :affiliates, :staged_header_image_file_size
    remove_column :affiliates, :staged_header_image_updated_at

    remove_column :affiliates, :staged_page_background_image_file_name
    remove_column :affiliates, :staged_page_background_image_content_type
    remove_column :affiliates, :staged_page_background_image_file_size
    remove_column :affiliates, :staged_page_background_image_updated_at

    remove_column :affiliates, :staged_mobile_logo_file_name
    remove_column :affiliates, :staged_mobile_logo_content_type
    remove_column :affiliates, :staged_mobile_logo_file_size
    remove_column :affiliates, :staged_mobile_logo_updated_at
  end

  def down
    add_column :affiliates, :staged_mobile_logo_updated_at, :datetime
    add_column :affiliates, :staged_mobile_logo_file_size, :integer
    add_column :affiliates, :staged_mobile_logo_content_type, :string
    add_column :affiliates, :staged_mobile_logo_file_name, :string

    add_column :affiliates, :staged_page_background_image_updated_at, :datetime
    add_column :affiliates, :staged_page_background_image_file_size, :integer
    add_column :affiliates, :staged_page_background_image_content_type, :string
    add_column :affiliates, :staged_page_background_image_file_name, :string

    add_column :affiliates, :staged_header_image_updated_at, :datetime
    add_column :affiliates, :staged_header_image_file_size, :integer
    add_column :affiliates, :staged_header_image_content_type, :string
    add_column :affiliates, :staged_header_image_file_name, :string
  end
end
