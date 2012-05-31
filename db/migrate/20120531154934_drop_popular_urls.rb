class DropPopularUrls < ActiveRecord::Migration
  def self.up
    drop_table :popular_urls
  end

  def self.down
    create_table :popular_urls do |t|
      t.integer :affiliate_id, :null => false
      t.string :title, :null => false
      t.string :url, :null => false
      t.integer :rank, :null => false

      t.timestamps
    end
    add_index :popular_urls, :affiliate_id
  end
end
