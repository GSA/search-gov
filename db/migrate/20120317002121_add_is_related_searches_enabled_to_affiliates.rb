class AddIsRelatedSearchesEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_related_searches_enabled, :boolean, :default => true
    update "UPDATE affiliates SET is_related_searches_enabled = 0 WHERE related_topics_setting = 'disabled'"
  end

  def self.down
    remove_column :affiliates, :is_related_searches_enabled
  end
end
