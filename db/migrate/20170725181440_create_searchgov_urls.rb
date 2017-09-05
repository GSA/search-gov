class CreateSearchgovUrls < ActiveRecord::Migration
  def change
    create_table :searchgov_urls do |t|
      t.string :url, limit: 2000, null: false
      t.datetime :last_crawled_at
      t.string :last_crawl_status
      t.integer :load_time

      t.timestamps
    end

    add_index :searchgov_urls, :url, unique: true, length: 100
  end
end
