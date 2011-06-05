class ModifyAgencyUrlsIndices < ActiveRecord::Migration
  def self.up
    remove_index :agency_urls, :agency_id
    remove_index :agency_urls, [:url, :locale, :agency_id]
    add_index :agency_urls, [:agency_id, :locale, :url]
  end

  def self.down
    remove_index :agency_urls, [:agency_id, :locale, :url]
    add_index :agency_urls, :agency_id
    add_index :agency_urls, [:url, :locale, :agency_id], :unique => true
  end
end
