class AddLocaleToAgencyPopularUrls < ActiveRecord::Migration
  def self.up
    add_column :agency_popular_urls, :locale, :string, :limit => 6, :null => false
    update "UPDATE agency_popular_urls SET locale = 'en' WHERE locale IS NULL OR locale = ''"
  end

  def self.down
    remove_column :agency_popular_urls, :locale
  end
end
