class SeedUsesManagedHeaderFooterColumnsOnAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.where(:uses_one_serp => true).each do |a|
      if a.header.blank? and a.footer.blank?
        a.uses_managed_header_footer = true
        a.staged_uses_managed_header_footer = true
        a.save!
      end
    end
  end

  def self.down
  end
end
