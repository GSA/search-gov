class AddIsPopularLinksEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_popular_links_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :affiliates, :is_popular_links_enabled
  end
end
