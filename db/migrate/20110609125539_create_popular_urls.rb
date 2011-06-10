class CreatePopularUrls < ActiveRecord::Migration
  def self.up
    create_table :popular_urls do |t|
      t.integer :affiliate_id, :null => false
      t.string :title, :null => false
      t.string :url, :null => false
      t.integer :rank, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :popular_urls
  end
end
