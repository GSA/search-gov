class SeedSiteDomains < ActiveRecord::Migration
  def self.up
    Affiliate.all.each do |affiliate|
      affiliate.domains.split.each do |domain|
        affiliate.add_site_domains(domain => domain)
      end unless affiliate.domains.blank?
    end
  end

  def self.down
  end
end
