class AddIndexOnSearchgovUrlsSearchgovDomainAndEnqueuedForReindex < ActiveRecord::Migration[7.0]
  def change
    add_index :searchgov_urls,
      [:searchgov_domain_id, :enqueued_for_reindex],
      name: 'searchgov_urls_on_searchgov_domain_id_and_enqueued_for_reindex'
  end
end
