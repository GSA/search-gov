class AddStagedFieldsToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :staged_domains, :string
    add_column :affiliates, :staged_header, :string
    add_column :affiliates, :staged_footer, :string
    add_column :affiliates, :has_staged_content, :boolean, :null=> false, :default => false
  end

  def self.down
    remove_column :affiliates, :staged_domains
    remove_column :affiliates, :staged_header
    remove_column :affiliates, :staged_footer
    remove_column :affiliates, :has_staged_content
  end
end
