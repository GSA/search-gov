class CreateFeaturedCollections < ActiveRecord::Migration
  def self.up
    create_table :featured_collections do |t|
      t.references :affiliate
      t.string :title, :null => false
      t.string :title_url
      t.string :locale, :null => false
      t.datetime :publish_start_at
      t.datetime :publish_end_at
      t.string :status, :null => false

      t.timestamps
    end

    add_index :featured_collections, :affiliate_id
  end

  def self.down
    drop_table :featured_collections
  end
end
