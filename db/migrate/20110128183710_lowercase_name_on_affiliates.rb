class LowercaseNameOnAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.all.each { |affiliate| affiliate.update_attribute(:name, affiliate.name.downcase) unless affiliate.name == affiliate.name.downcase }
  end

  def self.down
  end
end
