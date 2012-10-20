class AddAffiliateToDailyLeftNavStat < ActiveRecord::Migration
  def change
    add_column :daily_left_nav_stats, :affiliate, :string, :null => false, :limit => 32
  end
end
