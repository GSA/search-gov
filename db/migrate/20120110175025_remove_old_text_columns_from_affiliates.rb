class RemoveOldTextColumnsFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :old_header
    remove_column :affiliates, :old_footer
    remove_column :affiliates, :old_header_footer_sass
    remove_column :affiliates, :old_header_footer_css

    remove_column :affiliates, :old_staged_header
    remove_column :affiliates, :old_staged_footer
    remove_column :affiliates, :old_staged_header_footer_sass
    remove_column :affiliates, :old_staged_header_footer_css
  end

  def self.down
    add_column :affiliates, :old_staged_header_footer_css, :text
    add_column :affiliates, :old_staged_header_footer_sass, :text
    add_column :affiliates, :old_staged_footer, :text
    add_column :affiliates, :old_staged_header, :text

    add_column :affiliates, :old_header_footer_css, :text
    add_column :affiliates, :old_header_footer_sass, :text
    add_column :affiliates, :old_footer, :text
    add_column :affiliates, :old_header, :text
  end
end
