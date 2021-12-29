class SeedStagedContentForAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.all.each { |aff| aff.update( :staged_domains => aff.domains, :staged_header => aff.header, :staged_footer => aff.footer) }
  end

  def self.down
  end
end
