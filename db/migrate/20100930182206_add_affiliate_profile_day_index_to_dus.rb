class AddAffiliateProfileDayIndexToDus < ActiveRecord::Migration
  def self.up
    add_index :daily_usage_stats, [:affiliate, :profile, :day], :name => 'apd', :unique => true  
  end

  def self.down
    remove_index :daily_usage_stats, :name => 'apd'
  end
end
