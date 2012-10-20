class PopulateDailyLeftNavStatAffiliate < ActiveRecord::Migration
  def up
    execute("update daily_left_nav_stats d, affiliates a set d.affiliate = a.name where d.affiliate_id=a.id")
  end

  def down
  end
end
