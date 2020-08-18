class AddIndicesToSearchgovUrls < ActiveRecord::Migration[5.2]
  def change
    add_index :searchgov_urls,
      [:searchgov_domain_id, :last_crawl_status],
      name: 'index_by_searchgov_domain_id_and_last_crawl_status'
    add_index :searchgov_urls,
      [:searchgov_domain_id, :last_crawled_at]
  end
end
