class CreateNewsItem < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.references :rss_feed, :null => false
      t.string :link, :null => false
      t.string :title, :null => false
      t.string :guid, :null => false
      t.text :description, :null => false
      t.datetime :published_at, :null => false

      t.datetime :created_at
    end
    add_index :news_items, [:rss_feed_id, :guid]
  end

  def self.down
    drop_table :news_items
  end
end
