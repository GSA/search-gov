class AlterAffiliatesTwitterProfilesToAffiliateTwitterSettings < ActiveRecord::Migration
  def change
    rename_table :affiliates_twitter_profiles, :affiliate_twitter_settings
    add_column :affiliate_twitter_settings, :id, :primary_key
    add_column :affiliate_twitter_settings, :show_lists, :boolean, default: false, null: false
    add_timestamps :affiliate_twitter_settings
  end
end
