class CreateAgencyPopularUrls < ActiveRecord::Migration

  def self.up
    create_table :agency_popular_urls do |t|
      t.references :agency, :null => false
      t.string :url, :null => false
      t.integer :rank, :null => false
      t.string :title, :null => false
    end
   add_index :agency_popular_urls, :agency_id
  end

  def self.down
    remove_index :agency_popular_urls, :agency_id
    drop_table :agency_popular_urls
  end

end
