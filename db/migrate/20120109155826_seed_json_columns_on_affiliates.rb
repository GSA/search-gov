class SeedJsonColumnsOnAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.reset_column_information

    Affiliate.all.each do |affiliate|
      affiliate.header = affiliate.old_header
      affiliate.staged_header = affiliate.old_staged_header
      affiliate.footer = affiliate.old_footer
      affiliate.staged_footer = affiliate.old_staged_footer
      affiliate.header_footer_sass = affiliate.old_header_footer_sass
      affiliate.staged_header_footer_sass = affiliate.old_staged_header_footer_sass
      affiliate.header_footer_css = affiliate.old_header_footer_css
      affiliate.staged_header_footer_css = affiliate.old_staged_header_footer_css

      affiliate.old_header = nil
      affiliate.old_staged_header = nil
      affiliate.old_footer = nil
      affiliate.old_staged_footer = nil
      affiliate.old_header_footer_sass = nil
      affiliate.old_staged_header_footer_sass = nil
      affiliate.old_header_footer_css = nil
      affiliate.old_staged_header_footer_css = nil
      affiliate.save!
    end
  end

  def self.down
  end
end
