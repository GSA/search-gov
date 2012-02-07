class MigrateLegacyTemplateAffiliatesToOneSerp < ActiveRecord::Migration
  def self.up
    Affiliate.where("uses_one_serp IS NULL or uses_one_serp = 0").each do |a|
      if a.header.blank? and a.footer.blank?
        a.uses_one_serp = true
        a.save!
      end
    end
  end

  def self.down
  end
end
