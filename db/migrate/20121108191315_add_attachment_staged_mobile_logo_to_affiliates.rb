class AddAttachmentStagedMobileLogoToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :staged_mobile_logo_file_name, :string
    add_column :affiliates, :staged_mobile_logo_content_type, :string
    add_column :affiliates, :staged_mobile_logo_file_size, :integer
    add_column :affiliates, :staged_mobile_logo_updated_at, :datetime
  end

  def self.down
    remove_column :affiliates, :staged_mobile_logo_file_name
    remove_column :affiliates, :staged_mobile_logo_content_type
    remove_column :affiliates, :staged_mobile_logo_file_size
    remove_column :affiliates, :staged_mobile_logo_updated_at
  end
end
