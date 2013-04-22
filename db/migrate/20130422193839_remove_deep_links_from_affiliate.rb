class RemoveDeepLinksFromAffiliate < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :show_deep_links
  end

  def self.down
    add_column :affiliates, :show_deep_links, :boolean, :default => false, :null => false
  end
end
