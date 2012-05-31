class RemoveIsPopularLinksEnabledFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :is_popular_links_enabled
  end

  def self.down
    add_column :affiliates, :is_popular_links_enabled, :boolean, :default => true
  end
end
