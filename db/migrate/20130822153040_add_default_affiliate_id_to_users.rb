class AddDefaultAffiliateIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_affiliate_id, :integer
  end
end
