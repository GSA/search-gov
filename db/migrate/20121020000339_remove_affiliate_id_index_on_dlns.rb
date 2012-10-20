class RemoveAffiliateIdIndexOnDlns < ActiveRecord::Migration
  def change
    remove_index :daily_left_nav_stats, [:affiliate_id, :day]
  end
end
