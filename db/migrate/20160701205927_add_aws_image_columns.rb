class AddAwsImageColumns < ActiveRecord::Migration
  def change
    add_column :featured_collections, :aws_image_file_name, :string
    add_column :featured_collections, :aws_image_content_type, :string
    add_column :featured_collections, :aws_image_file_size, :integer
    add_column :featured_collections, :aws_image_updated_at, :datetime

    add_column :affiliates, :aws_page_background_image_file_name, :string
    add_column :affiliates, :aws_page_background_image_content_type, :string
    add_column :affiliates, :aws_page_background_image_file_size, :integer
    add_column :affiliates, :aws_page_background_image_updated_at, :datetime

    add_column :affiliates, :aws_header_image_file_name, :string
    add_column :affiliates, :aws_header_image_content_type, :string
    add_column :affiliates, :aws_header_image_file_size, :integer
    add_column :affiliates, :aws_header_image_updated_at, :datetime

    add_column :affiliates, :aws_mobile_logo_file_name, :string
    add_column :affiliates, :aws_mobile_logo_content_type, :string
    add_column :affiliates, :aws_mobile_logo_file_size, :integer
    add_column :affiliates, :aws_mobile_logo_updated_at, :datetime

    add_column :affiliates, :aws_header_tagline_logo_file_name, :string
    add_column :affiliates, :aws_header_tagline_logo_content_type, :string
    add_column :affiliates, :aws_header_tagline_logo_file_size, :integer
    add_column :affiliates, :aws_header_tagline_logo_updated_at, :datetime
  end
end
