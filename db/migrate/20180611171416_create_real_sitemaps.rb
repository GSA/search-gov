class CreateRealSitemaps < ActiveRecord::Migration
  def change
    create_table :sitemaps do |t|
      t.belongs_to :searchgov_domain, index: true
      t.string :url, null: false, limit: 2000
      t.string :last_crawl_status
      t.datetime :last_crawled_at

      t.timestamps null: false
    end
  end
end
