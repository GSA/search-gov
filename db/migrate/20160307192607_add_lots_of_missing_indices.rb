class AddLotsOfMissingIndices < ActiveRecord::Migration
  def change
    add_index :suggestion_blocks, :query
    add_index :rss_feed_urls_rss_feeds, :rss_feed_url_id
    add_index :agency_organization_codes, :agency_id
    add_index :outbound_rate_limits, :name
    add_index :affiliates_youtube_profiles, :youtube_profile_id
    add_index :affiliate_twitter_settings, :twitter_profile_id
    add_index :federal_register_agencies_federal_register_documents, :federal_register_document_id, name: 'fra_frd_frdocid_idx'
    add_index :whitelisted_v1_api_handles, :handle
  end
end
