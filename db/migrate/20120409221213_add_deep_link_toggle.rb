class AddDeepLinkToggle < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :show_deep_links, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :affiliates, :show_deep_links
  end
end
