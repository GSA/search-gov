class RenameLiveAndStagedColumnsOnAffiliates < ActiveRecord::Migration
  def self.up
    rename_column :affiliates, :header, :old_header
    rename_column :affiliates, :footer, :old_footer
    rename_column :affiliates, :header_footer_sass, :old_header_footer_sass
    rename_column :affiliates, :header_footer_css, :old_header_footer_css

    rename_column :affiliates, :staged_header, :old_staged_header
    rename_column :affiliates, :staged_footer, :old_staged_footer
    rename_column :affiliates, :staged_header_footer_sass, :old_staged_header_footer_sass
    rename_column :affiliates, :staged_header_footer_css, :old_staged_header_footer_css
  end

  def self.down
    rename_column :affiliates, :old_staged_header_footer_css, :staged_header_footer_css
    rename_column :affiliates, :old_staged_header_footer_sass, :staged_header_footer_sass
    rename_column :affiliates, :old_staged_footer, :staged_footer
    rename_column :affiliates, :old_staged_header, :staged_header

    rename_column :affiliates, :old_header_footer_css, :header_footer_css
    rename_column :affiliates, :old_header_footer_sass, :header_footer_sass
    rename_column :affiliates, :old_footer, :footer
    rename_column :affiliates, :old_header, :header
  end
end
