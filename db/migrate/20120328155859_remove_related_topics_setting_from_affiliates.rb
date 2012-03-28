class RemoveRelatedTopicsSettingFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :related_topics_setting
  end

  def self.down
    add_column :affiliates, :related_topics_setting, :string, :limit => 30, :default => 'affiliate_enabled'
  end
end
