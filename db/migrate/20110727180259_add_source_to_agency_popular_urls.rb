class AddSourceToAgencyPopularUrls < ActiveRecord::Migration
  def self.up
    add_column :agency_popular_urls, :source, :string, :default => 'admin'
  end

  def self.down
    remove_column :agency_popular_urls, :source
  end
end
