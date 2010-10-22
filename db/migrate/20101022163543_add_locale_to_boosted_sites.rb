class AddLocaleToBoostedSites < ActiveRecord::Migration
  def self.up
    add_column :boosted_sites, :locale, :string, :limit => 6, :default => "en", :null => false
  end

  def self.down
    remove_column :boosted_sites, :locale
  end
end
