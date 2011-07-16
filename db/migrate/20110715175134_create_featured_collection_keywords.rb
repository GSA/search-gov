class CreateFeaturedCollectionKeywords < ActiveRecord::Migration
  def self.up
    create_table :featured_collection_keywords do |t|
      t.references :featured_collection, :null => false
      t.string :value, :null => false

      t.timestamps
    end

    add_index :featured_collection_keywords, :featured_collection_id
  end

  def self.down
    drop_table :featured_collection_keywords
  end
end
