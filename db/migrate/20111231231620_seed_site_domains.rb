class SeedSiteDomains < ActiveRecord::Migration
  def self.up
    Affiliate.all.each do |affiliate|
      unless affiliate.domains.blank?
        affiliate_hash_params = Hash[affiliate.domains.split.collect { |domain| [domain, nil] }]
        affiliate.add_site_domains(affiliate_hash_params)
      end
    end
  end

  def self.down
  end
end
