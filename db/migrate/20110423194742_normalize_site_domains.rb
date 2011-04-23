class NormalizeSiteDomains < ActiveRecord::Migration
  def self.up
    Affiliate.all.each do |affiliate|
      affiliate.normalize_domains(false)
      affiliate.save
    end
  end

  def self.down
  end
end
