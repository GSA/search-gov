class AddRelatedTopicsFieldToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :related_topics_setting, :string, :limit => 30, :default => 'affiliate_enabled'
  end

  def self.down
    remove_column :affiliates, :related_topics_setting
  end
end
