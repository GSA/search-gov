class CreateSearchgovUrlsFetchRequiredIndex < ActiveRecord::Migration[7.0]
  def change
   add_index :searchgov_urls,
     %i[searchgov_domain_id last_crawled_at lastmod enqueued_for_reindex last_crawl_status],
     order: {last_crawl_status: :asc, enqueued_for_reindex: :desc, lastmod: :desc},
     name: :searchgov_urls_fetch_required
  end
end
