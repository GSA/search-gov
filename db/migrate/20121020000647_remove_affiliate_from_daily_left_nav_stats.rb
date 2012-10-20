class RemoveAffiliateFromDailyLeftNavStats < ActiveRecord::Migration
  def change
    remove_column :daily_left_nav_stats, :affiliate_id
  end
end
