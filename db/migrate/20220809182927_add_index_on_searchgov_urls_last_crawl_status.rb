class AddIndexOnSearchgovUrlsLastCrawlStatus < ActiveRecord::Migration[6.1]
  def change
    add_index :searchgov_urls, :last_crawl_status
  end
end
