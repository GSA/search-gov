class CreateSearchgovUrlsFetchRequiredIndex < ActiveRecord::Migration[7.0]
  def change
   add_index :searchgov_urls,
     %i[searchgov_domain_id last_crawled_at enqueued_for_reindex lastmod last_crawl_status],
     order: {enqueued_for_reindex: :desc, lastmod: :desc, last_crawl_status: :asc},
     name: :searchgov_urls_fetch_required
  end
end
