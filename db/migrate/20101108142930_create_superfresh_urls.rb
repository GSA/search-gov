class CreateSuperfreshUrls < ActiveRecord::Migration
  def self.up
    create_table :superfresh_urls do |t|
      t.text :url
      t.timestamp :crawled_at
      t.references :affiliate

      t.timestamps
    end
  end

  def self.down
    drop_table :superfresh_urls
  end
end
