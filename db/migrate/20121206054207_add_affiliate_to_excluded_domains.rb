class AddAffiliateToExcludedDomains < ActiveRecord::Migration
  def change
    usagov_id = Affiliate.find_by_name("usagov").id rescue 0
    add_column :excluded_domains, :affiliate_id, :integer, :null => false, :default => usagov_id
    add_index :excluded_domains, :affiliate_id
  end
end
