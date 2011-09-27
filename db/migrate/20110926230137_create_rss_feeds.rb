class CreateRssFeeds < ActiveRecord::Migration
  def self.up
    create_table :rss_feeds do |t|
      t.references :affiliate, :null => false
      t.string :url, :null => false
      t.string :name, :null => false

      t.timestamps
    end
    add_index :rss_feeds, :affiliate_id
  end

  def self.down
    drop_table :rss_feeds
  end
end
