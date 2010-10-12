class AllowNilAffiliateIdForBoostedSites < ActiveRecord::Migration
  def self.up
    change_column :boosted_sites, :affiliate_id, :integer, :null => true
  end

  def self.down
    change_column :boosted_sites, :affiliate_id, :integer, :null => false
  end
end
