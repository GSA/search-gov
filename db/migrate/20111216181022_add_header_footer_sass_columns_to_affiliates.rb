class AddHeaderFooterSassColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :header_footer_sass, :text
    add_column :affiliates, :staged_header_footer_sass, :text
  end

  def self.down
    remove_column :affiliates, :staged_header_footer_sass
    remove_column :affiliates, :header_footer_sass
  end
end
