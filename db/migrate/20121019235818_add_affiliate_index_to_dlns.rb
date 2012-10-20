class AddAffiliateIndexToDlns < ActiveRecord::Migration
  def change
    add_index :daily_left_nav_stats, [:affiliate, :day]
  end
end
