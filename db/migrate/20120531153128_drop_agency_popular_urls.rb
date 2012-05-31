class DropAgencyPopularUrls < ActiveRecord::Migration
  def self.up
    drop_table :agency_popular_urls
  end

  def self.down
    create_table :agency_popular_urls do |t|
      t.integer :agency_id, :null => false
      t.string :url, :null => false
      t.integer :rank, :null => false
      t.string :title, :null => false
      t.string :source, :default => 'admin'
      t.string :locale, :limit => 6, :null => false
    end
    add_index :agency_popular_urls, :agency_id
  end
end
