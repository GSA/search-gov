class AddIsTwitterGovboxEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_twitter_govbox_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :affiliates, :is_twitter_govbox_enabled
  end
end
