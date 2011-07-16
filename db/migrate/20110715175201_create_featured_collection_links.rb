class CreateFeaturedCollectionLinks < ActiveRecord::Migration
  def self.up
    create_table :featured_collection_links do |t|
      t.references :featured_collection, :null => false
      t.integer :position, :null => false
      t.string :title, :null => false
      t.string :url, :null => false

      t.timestamps
    end

    add_index :featured_collection_links, :featured_collection_id
  end

  def self.down
    drop_table :featured_collection_links
  end
end
