class CreateSiteUrls < ActiveRecord::Migration
  def change
    create_table :site_feed_urls do |t|
      t.references :affiliate, null: false
      t.string :rss_url, null: false
      t.string :last_fetch_status, default: 'Pending', null: false
      t.datetime :last_checked_at
      t.integer :quota, null: false, default: 500

      t.timestamps
    end

    add_index :site_feed_urls, :affiliate_id, unique: true
  end
end
