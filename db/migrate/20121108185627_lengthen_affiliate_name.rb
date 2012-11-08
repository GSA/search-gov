class LengthenAffiliateName < ActiveRecord::Migration
  def up
    change_column :daily_usage_stats, :affiliate, :string, :limit => 33, :default => 'usagov'
    change_column :daily_left_nav_stats, :affiliate, :string, :limit => 33, :null => false
    change_column :daily_click_stats, :affiliate, :string, :limit => 33, :null => false
    change_column :daily_query_stats, :affiliate, :string, :limit => 33, :default => 'usagov'
    change_column :queries_clicks_stats, :affiliate, :string, :limit => 33, :null => false
  end

  def down
    change_column :daily_usage_stats, :affiliate, :string, :limit => 32, :default => 'usasearch.gov'
    change_column :daily_left_nav_stats, :affiliate, :string, :limit => 32, :null => false
    change_column :daily_click_stats, :affiliate, :string, :limit => 32, :null => false
    change_column :daily_query_stats, :affiliate, :string, :limit => 32, :default => 'usasearch.gov'
    change_column :queries_clicks_stats, :affiliate, :string, :limit => 32, :null => false
  end
end
