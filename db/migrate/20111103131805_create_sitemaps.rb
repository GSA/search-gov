class CreateSitemaps < ActiveRecord::Migration
  def self.up
    create_table :sitemaps do |t|
      t.string :url
      t.references :affiliate
      t.timestamp :last_crawled_at

      t.timestamps
    end
    add_index :sitemaps, :affiliate_id
  end

  def self.down
    drop_table :sitemaps
  end
end