class AddHeaderFooterCssColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :header_footer_css, :text
    add_column :affiliates, :staged_header_footer_css, :text
  end

  def self.down
    remove_column :affiliates, :staged_header_footer_css
    remove_column :affiliates, :header_footer_css
  end
end
