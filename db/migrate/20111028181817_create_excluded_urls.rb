class CreateExcludedUrls < ActiveRecord::Migration
  def self.up
    create_table :excluded_urls do |t|
      t.text :url
      t.references :affiliate

      t.timestamps
    end
    add_index :excluded_urls, :affiliate_id
  end

  def self.down
    drop_table :excluded_urls
  end
end
