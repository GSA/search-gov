# frozen_string_literal: true

class DropUnusedAffiliatesColumns < ActiveRecord::Migration[5.2]
  def up
    columns = %i[
      external_css_url
      force_mobile_format
      has_staged_content
      header_image_content_type
      header_image_file_name
      header_image_file_size
      header_image_updated_at
      page_background_image_content_type
      page_background_image_file_name
      page_background_image_file_size
      page_background_image_updated_at
      previous_fields_json
      rackspace_header_image_content_type
      rackspace_header_image_file_name
      rackspace_header_image_file_size
      rackspace_header_image_updated_at
      rackspace_header_tagline_logo_content_type
      rackspace_header_tagline_logo_file_name
      rackspace_header_tagline_logo_file_size
      rackspace_header_tagline_logo_updated_at
      rackspace_mobile_logo_content_type
      rackspace_mobile_logo_file_name
      rackspace_mobile_logo_file_size
      rackspace_mobile_logo_updated_at
      rackspace_page_background_image_content_type
      rackspace_page_background_image_file_name
      rackspace_page_background_image_file_size
      rackspace_page_background_image_updated_at
      staged_fields_json
      staged_uses_managed_header_footer
      uses_managed_header_footer
    ]
    drop_statements = columns.map { |c| "DROP COLUMN #{c}" }.join(', ')

    # Rails 7 will automatically run a single 'ALTER TABLE' statement to drop
    # multiple columns. For now, we need to use raw SQL to optimize the drops
    execute "ALTER TABLE affiliates #{drop_statements}"
  end

  def down
    change_table(:affiliates, bulk: true) do |t|
      t.column :external_css_url, :string
      t.column :force_mobile_format, :boolean, null: false, default: true
      t.column :has_staged_content, :boolean, null: false, default: false
      t.column :header_image_content_type, :string
      t.column :header_image_file_name, :string
      t.column :header_image_file_size, :integer
      t.column :header_image_updated_at, :datetime
      t.column :page_background_image_content_type, :string
      t.column :page_background_image_file_name, :string
      t.column :page_background_image_file_size, :integer
      t.column :page_background_image_updated_at, :datetime
      t.column :previous_fields_json, :longtext
      t.column :rackspace_header_image_content_type, :string
      t.column :rackspace_header_image_file_name, :string
      t.column :rackspace_header_image_file_size, :integer
      t.column :rackspace_header_image_updated_at, :datetime
      t.column :rackspace_header_tagline_logo_content_type, :string
      t.column :rackspace_header_tagline_logo_file_name, :string
      t.column :rackspace_header_tagline_logo_file_size, :integer
      t.column :rackspace_header_tagline_logo_updated_at, :datetime
      t.column :rackspace_mobile_logo_content_type, :string
      t.column :rackspace_mobile_logo_file_name, :string
      t.column :rackspace_mobile_logo_file_size, :integer
      t.column :rackspace_mobile_logo_updated_at, :datetime
      t.column :rackspace_page_background_image_content_type, :string
      t.column :rackspace_page_background_image_file_name, :string
      t.column :rackspace_page_background_image_file_size, :integer
      t.column :rackspace_page_background_image_updated_at, :datetime
      t.column :staged_fields_json, :longtext
      t.column :staged_uses_managed_header_footer, :boolean
      t.column :uses_managed_header_footer, :boolean
    end
  end
end
