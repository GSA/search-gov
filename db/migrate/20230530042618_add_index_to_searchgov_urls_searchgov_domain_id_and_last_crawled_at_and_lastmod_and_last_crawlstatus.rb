class AddIndexToSearchgovUrlsSearchgovDomainIdAndLastCrawledAtAndLastmodAndLastCrawlstatus < ActiveRecord::Migration[7.0]
  def change
    add_index :searchgov_urls,
    [:searchgov_domain_id, :last_crawled_at],
    name: 'searchgov_urls_on_searchgov_domain_id_and_last_crawled_at'
    add_index :searchgov_urls,
    [:searchgov_domain_id, :lastmod],
    name: 'searchgov_urls_on_searchgov_domain_id_and_lastmod'
    add_index :searchgov_urls,
    [:searchgov_domain_id, :last_crawl_status],
    name: 'searchgov_urls_on_searchgov_domain_id_and_last_crawl_status'
  end
end
