class AddAffiliateToDailyUsageStat < ActiveRecord::Migration
  def self.up
    add_column :daily_usage_stats, :affiliate, :string, :limit => 32, :default => 'usasearch.gov'
  end

  def self.down
    remove_column :daily_usage_stats, :affiliate
  end
end
