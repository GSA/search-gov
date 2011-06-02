class AddIndicesToAgencyUrls < ActiveRecord::Migration
  def self.up
    add_index :agency_urls, :agency_id
    add_index :agency_urls, [:url, :locale, :agency_id], :unique => true
  end

  def self.down
    remove_index :agency_urls, :agency_id
    remove_index :agency_urls, [:url, :locale, :agency_id]
  end
end
