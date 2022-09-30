# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_23_172333) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "affiliate_feature_additions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.integer "feature_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["affiliate_id", "feature_id"], name: "index_affiliate_feature_additions_on_affiliate_id_and_feature_id", unique: true
  end

  create_table "affiliate_twitter_settings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.integer "twitter_profile_id", null: false
    t.boolean "show_lists", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id", "twitter_profile_id"], name: "aff_id_tp_id"
    t.index ["twitter_profile_id"], name: "index_affiliate_twitter_settings_on_twitter_profile_id"
  end

  create_table "affiliates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "website"
    t.boolean "is_sayt_enabled", default: true
    t.string "display_name", null: false
    t.string "favicon_url"
    t.text "css_properties", size: :medium
    t.string "theme"
    t.string "locale", default: "en", null: false
    t.text "scope_ids", size: :medium
    t.boolean "is_medline_govbox_enabled", default: false
    t.text "live_fields_json", size: :long
    t.integer "fetch_concurrency", default: 1, null: false
    t.string "default_search_label", limit: 20, null: false
    t.boolean "is_related_searches_enabled", default: true
    t.string "left_nav_label", limit: 20
    t.string "ga_web_property_id", limit: 20
    t.boolean "is_photo_govbox_enabled", default: false
    t.boolean "jobs_enabled", default: false, null: false
    t.integer "agency_id"
    t.boolean "raw_log_access_enabled", default: false, null: false
    t.string "search_engine", default: "BingV7", null: false
    t.boolean "is_rss_govbox_enabled", default: false, null: false
    t.string "rss_govbox_label", null: false
    t.boolean "is_video_govbox_enabled", default: true, null: false
    t.boolean "dap_enabled", default: true, null: false
    t.text "dublin_core_mappings", size: :medium
    t.boolean "gets_blended_results", default: false, null: false
    t.boolean "is_bing_image_search_enabled", default: true, null: false
    t.boolean "is_federal_register_document_govbox_enabled", default: false, null: false
    t.string "google_cx"
    t.string "google_key"
    t.string "api_access_key", null: false
    t.boolean "gets_commercial_results_on_blended_search", default: true, null: false
    t.boolean "gets_i14y_results", default: false, null: false
    t.string "domain_control_validation_code"
    t.boolean "i14y_date_stamp_enabled", default: false, null: false
    t.string "mobile_logo_file_name"
    t.string "mobile_logo_content_type"
    t.integer "mobile_logo_file_size"
    t.datetime "mobile_logo_updated_at", precision: nil
    t.string "header_tagline_logo_file_name"
    t.string "header_tagline_logo_content_type"
    t.integer "header_tagline_logo_file_size"
    t.datetime "header_tagline_logo_updated_at", precision: nil
    t.string "bing_v5_key", limit: 32
    t.boolean "active", default: true, null: false
    t.index ["name"], name: "index_affiliates_on_name", unique: true
  end

  create_table "affiliates_youtube_profiles", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "youtube_profile_id"
    t.index ["affiliate_id", "youtube_profile_id"], name: "affiliate_id_youtube_profile_id", unique: true
    t.index ["youtube_profile_id"], name: "index_affiliates_youtube_profiles_on_youtube_profile_id"
  end

  create_table "agencies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "abbreviation"
    t.integer "federal_register_agency_id"
  end

  create_table "agency_organization_codes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "agency_id"
    t.string "organization_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["agency_id"], name: "index_agency_organization_codes_on_agency_id"
  end

  create_table "alerts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "status"
    t.text "text", size: :medium
    t.text "title", size: :medium
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id"], name: "index_alerts_on_affiliate_id", unique: true
  end

  create_table "boosted_content_keywords", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "boosted_content_id", null: false
    t.string "value", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["boosted_content_id"], name: "index_boosted_content_keywords_on_boosted_content_id"
  end

  create_table "boosted_contents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "title", null: false
    t.string "url", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "status", null: false
    t.date "publish_start_on", null: false
    t.date "publish_end_on"
    t.boolean "match_keyword_values_only", default: false
    t.index ["affiliate_id", "title"], name: "index_boosted_contents_on_affiliate_id_and_title"
  end

  create_table "catalog_prefixes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "prefix", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "connections", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.integer "connected_affiliate_id", null: false
    t.string "label", limit: 50, null: false
    t.integer "position", default: 100, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id"], name: "index_connections_on_affiliate_id"
  end

  create_table "document_collections", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id", "name"], name: "index_document_collections_on_affiliate_id_and_name", unique: true
  end

  create_table "email_templates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "body", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "subject"
  end

  create_table "excluded_domains", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "domain"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "affiliate_id", default: 1, null: false
    t.index ["affiliate_id"], name: "index_excluded_domains_on_affiliate_id"
  end

  create_table "excluded_urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "url", size: :medium
    t.integer "affiliate_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id"], name: "index_excluded_urls_on_affiliate_id"
  end

  create_table "featured_collection_keywords", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "featured_collection_id", null: false
    t.string "value", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["featured_collection_id"], name: "index_featured_collection_keywords_on_featured_collection_id"
  end

  create_table "featured_collection_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "featured_collection_id", null: false
    t.integer "position", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["featured_collection_id"], name: "index_featured_collection_links_on_featured_collection_id"
  end

  create_table "featured_collections", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "title", null: false
    t.string "title_url"
    t.string "status", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "publish_start_on", null: false
    t.date "publish_end_on"
    t.string "rackspace_image_file_name"
    t.string "rackspace_image_content_type"
    t.integer "rackspace_image_file_size"
    t.datetime "rackspace_image_updated_at", precision: nil
    t.string "image_alt_text"
    t.boolean "match_keyword_values_only", default: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.index ["affiliate_id"], name: "index_featured_collections_on_affiliate_id"
  end

  create_table "features", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "internal_name", null: false
    t.string "display_name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["internal_name"], name: "index_features_on_internal_name"
  end

  create_table "federal_register_agencies", id: :integer, default: nil, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "last_load_documents_requested_at", precision: nil
    t.datetime "last_successful_load_documents_at", precision: nil
    t.integer "parent_id"
  end

  create_table "federal_register_agencies_federal_register_documents", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "federal_register_agency_id", null: false
    t.integer "federal_register_document_id", null: false
    t.index ["federal_register_agency_id", "federal_register_document_id"], name: "index_federal_register_agencies_federal_register_documents", unique: true
    t.index ["federal_register_document_id"], name: "fra_frd_frdocid_idx"
  end

  create_table "federal_register_documents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "document_number", null: false
    t.text "title", size: :medium, null: false
    t.text "abstract", size: :medium
    t.string "html_url", null: false
    t.string "document_type", null: false
    t.integer "start_page", null: false
    t.integer "end_page", null: false
    t.integer "page_length", null: false
    t.date "publication_date", null: false
    t.date "comments_close_on"
    t.date "effective_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "docket_id"
    t.boolean "significant", default: false, null: false
  end

  create_table "flickr_profiles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "url"
    t.string "profile_type"
    t.string "profile_id"
    t.integer "affiliate_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id"], name: "index_flickr_profiles_on_affiliate_id"
  end

  create_table "help_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "request_path"
    t.string "help_page_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["request_path"], name: "index_help_links_on_request_path"
  end

  create_table "hints", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_hints_on_name", unique: true
  end

  create_table "i14y_drawers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "handle", null: false
    t.string "token", null: false
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "i14y_memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.integer "i14y_drawer_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id", "i14y_drawer_id"], name: "index_i14y_memberships_on_affiliate_id_and_i14y_drawer_id", unique: true
    t.index ["i14y_drawer_id"], name: "index_i14y_memberships_on_i14y_drawer_id"
  end

  create_table "image_search_labels", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id"], name: "index_image_search_labels_on_affiliate_id", unique: true
  end

  create_table "indexed_documents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "title", size: :medium
    t.text "description", size: :medium
    t.string "url", limit: 2000
    t.integer "affiliate_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "body", size: :long
    t.string "doctype", limit: 10
    t.datetime "last_crawled_at", precision: nil
    t.string "last_crawl_status"
    t.integer "load_time"
    t.string "source", default: "rss", null: false
    t.datetime "published_at", precision: nil
    t.index ["affiliate_id", "id"], name: "index_indexed_documents_on_affiliate_id_and_id", unique: true
    t.index ["affiliate_id", "url"], name: "by_aid_url", length: { url: 50 }
  end

  create_table "languages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.boolean "is_google_supported", default: false, null: false
    t.boolean "is_bing_supported", default: false, null: false
    t.boolean "rtl", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "inferred_country_code"
    t.boolean "is_azure_supported", default: false
    t.index ["code"], name: "index_languages_on_code", unique: true
  end

  create_table "med_related_topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "med_topic_id", null: false
    t.integer "related_medline_tid", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["med_topic_id"], name: "index_med_related_topics_on_med_topic_id"
  end

  create_table "med_sites", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "med_topic_id", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["med_topic_id"], name: "index_med_sites_on_med_topic_id"
  end

  create_table "med_synonyms", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "medline_title", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["medline_title"], name: "index_med_synonyms_on_medline_title"
  end

  create_table "med_topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "medline_tid"
    t.string "medline_title", null: false
    t.string "medline_url", limit: 120
    t.string "locale", limit: 5, default: "en"
    t.text "summary_html", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["medline_tid"], name: "index_med_topics_on_medline_tid"
    t.index ["medline_title"], name: "index_med_topics_on_medline_title"
  end

  create_table "memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "affiliate_id", null: false
    t.boolean "gets_daily_snapshot_email", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id", "user_id"], name: "index_memberships_on_affiliate_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "misspellings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "wrong"
    t.string "rite"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["wrong"], name: "index_misspellings_on_wrong"
  end

  create_table "navigations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.integer "navigable_id", null: false
    t.string "navigable_type", null: false
    t.integer "position", default: 100, null: false
    t.boolean "is_active", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id"], name: "index_navigations_on_affiliate_id"
    t.index ["navigable_id", "navigable_type"], name: "index_navigations_on_navigable_id_and_navigable_type"
  end

  create_table "news_items", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "link", null: false
    t.string "title", null: false
    t.string "guid", null: false
    t.text "description", size: :medium
    t.datetime "published_at", precision: nil, null: false
    t.datetime "created_at", precision: nil
    t.integer "rss_feed_url_id", null: false
    t.datetime "updated_at", precision: nil
    t.text "contributor", size: :medium
    t.text "subject", size: :medium
    t.text "publisher", size: :medium
    t.text "properties", size: :medium
    t.text "body", size: :long
    t.index ["link"], name: "index_news_items_on_link"
    t.index ["rss_feed_url_id", "guid"], name: "index_news_items_on_rss_feed_url_id_and_guid"
    t.index ["rss_feed_url_id", "link"], name: "index_news_items_on_rss_feed_url_id_and_link", unique: true
  end

  create_table "outbound_rate_limits", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "limit", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "interval", limit: 10, default: "day"
    t.index ["name"], name: "index_outbound_rate_limits_on_name"
  end

  create_table "routed_queries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "url"
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id"], name: "index_routed_queries_on_affiliate_id"
  end

  create_table "routed_query_keywords", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "routed_query_id"
    t.string "keyword"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["routed_query_id", "keyword"], name: "index_routed_query_keywords_on_routed_query_id_and_keyword", unique: true
  end

  create_table "rss_feed_urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "rss_feed_owner_type", null: false
    t.string "url", null: false
    t.datetime "last_crawled_at", precision: nil
    t.string "last_crawl_status", default: "Pending", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "language"
    t.string "oasis_mrss_name"
    t.index ["rss_feed_owner_type", "url"], name: "index_rss_feed_urls_on_rss_feed_owner_type_and_url", unique: true
  end

  create_table "rss_feed_urls_rss_feeds", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "rss_feed_url_id", null: false
    t.integer "rss_feed_id", null: false
    t.index ["rss_feed_id", "rss_feed_url_id"], name: "index_rss_feed_urls_rss_feeds_on_rss_feed_id_and_rss_feed_url_id", unique: true
    t.index ["rss_feed_url_id"], name: "index_rss_feed_urls_rss_feeds_on_rss_feed_url_id"
  end

  create_table "rss_feeds", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "is_managed", default: false, null: false
    t.boolean "is_video", default: false, null: false
    t.string "owner_type", null: false
    t.boolean "show_only_media_content", default: false, null: false
    t.index ["owner_id"], name: "index_rss_feeds_on_affiliate_id"
    t.index ["owner_type", "owner_id"], name: "index_rss_feeds_on_owner_type_and_owner_id"
  end

  create_table "sayt_filters", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "phrase", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "filter_only_exact_phrase", default: false, null: false
    t.boolean "is_regex", default: false, null: false
    t.boolean "accept", default: false, null: false
    t.index ["phrase"], name: "index_sayt_filters_on_phrase", unique: true
  end

  create_table "sayt_suggestions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "phrase", null: false
    t.datetime "created_at", precision: nil
    t.integer "popularity", default: 1, null: false
    t.datetime "updated_at", precision: nil
    t.integer "affiliate_id"
    t.boolean "is_protected", default: false
    t.datetime "deleted_at", precision: nil
    t.boolean "is_whitelisted", default: false, null: false
    t.index ["affiliate_id", "phrase"], name: "index_sayt_suggestions_on_affiliate_id_and_phrase", unique: true
    t.index ["updated_at", "is_protected"], name: "index_sayt_suggestions_on_updated_at_and_is_protected"
  end

  create_table "search_modules", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "tag", null: false
    t.string "display_name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["tag"], name: "index_search_modules_on_tag", unique: true
  end

  create_table "searchgov_documents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "web_document", size: :long, null: false
    t.json "headers", null: false
    t.decimal "tika_version", precision: 10, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "searchgov_url_id"
    t.index ["searchgov_url_id"], name: "index_searchgov_documents_on_searchgov_url_id"
  end

  create_table "searchgov_domains", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "domain", null: false
    t.boolean "clean_urls", default: true, null: false
    t.string "status"
    t.integer "urls_count", default: 0, null: false
    t.integer "unfetched_urls_count", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "scheme", limit: 5, default: "http", null: false
    t.string "activity", limit: 100, default: "idle", null: false
    t.string "canonical_domain"
    t.index ["activity"], name: "index_searchgov_domains_on_activity"
    t.index ["domain"], name: "index_searchgov_domains_on_domain", unique: true, length: 100
    t.index ["status"], name: "index_searchgov_domains_on_status", length: 100
  end

  create_table "searchgov_urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "url", limit: 2000, null: false, collation: "utf8mb4_bin"
    t.datetime "last_crawled_at", precision: nil
    t.string "last_crawl_status"
    t.integer "load_time"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "searchgov_domain_id"
    t.datetime "lastmod", precision: nil
    t.boolean "enqueued_for_reindex", default: false, null: false
    t.index ["last_crawl_status"], name: "index_searchgov_urls_on_last_crawl_status"
    t.index ["searchgov_domain_id", "last_crawl_status"], name: "index_by_searchgov_domain_id_and_last_crawl_status"
    t.index ["searchgov_domain_id", "last_crawled_at"], name: "index_searchgov_urls_on_searchgov_domain_id_and_last_crawled_at"
    t.index ["searchgov_domain_id"], name: "index_searchgov_urls_on_searchgov_domain_id"
    t.index ["url"], name: "index_searchgov_urls_on_url", length: 255
  end

  create_table "site_domains", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.string "site_name", null: false
    t.string "domain", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id", "domain"], name: "index_site_domains_on_affiliate_id_and_domain", unique: true
  end

  create_table "site_feed_urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.string "rss_url", null: false
    t.string "last_fetch_status", default: "Pending", null: false
    t.datetime "last_checked_at", precision: nil
    t.integer "quota", default: 1000, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id"], name: "index_site_feed_urls_on_affiliate_id", unique: true
  end

  create_table "sitemaps", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "searchgov_domain_id"
    t.string "url", limit: 2000, null: false
    t.string "last_crawl_status"
    t.datetime "last_crawled_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["searchgov_domain_id"], name: "index_sitemaps_on_searchgov_domain_id"
  end

  create_table "suggestion_blocks", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "query", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["query"], name: "index_suggestion_blocks_on_query"
  end

  create_table "superfresh_urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "url", size: :medium
    t.integer "affiliate_id"
    t.datetime "created_at", precision: nil
    t.index ["affiliate_id"], name: "index_superfresh_urls_on_affiliate_id"
  end

  create_table "system_alerts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "message", null: false
    t.datetime "start_at", precision: nil, null: false
    t.datetime "end_at", precision: nil
  end

  create_table "tag_filters", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "affiliate_id", null: false
    t.string "tag"
    t.boolean "exclude"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["affiliate_id"], name: "index_tag_filters_on_affiliate_id"
  end

  create_table "top_searches", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "query"
    t.string "url"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "affiliate_id"
    t.index ["affiliate_id"], name: "index_top_searches_on_affiliate_id"
    t.index ["position", "affiliate_id"], name: "index_top_searches_on_position_and_affiliate_id", unique: true
  end

  create_table "tweets", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "tweet_id", null: false, unsigned: true
    t.string "tweet_text"
    t.bigint "twitter_profile_id", null: false, unsigned: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "published_at", precision: nil
    t.text "urls", size: :medium
    t.index ["published_at"], name: "index_tweets_on_published_at"
    t.index ["tweet_id"], name: "index_tweets_on_tweet_id", unique: true
    t.index ["twitter_profile_id"], name: "index_tweets_on_twitter_profile_id"
  end

  create_table "twitter_lists", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "id", null: false, unsigned: true
    t.text "member_ids", size: :long
    t.bigint "last_status_id", default: 1, null: false, unsigned: true
    t.string "statuses_updated_at"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["id"], name: "index_twitter_lists_on_id", unique: true
  end

  create_table "twitter_lists_twitter_profiles", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "twitter_list_id", null: false, unsigned: true
    t.integer "twitter_profile_id", null: false
    t.index ["twitter_list_id", "twitter_profile_id"], name: "twitter_list_id_profile_id", unique: true
    t.index ["twitter_profile_id"], name: "index_twitter_lists_twitter_profiles_on_twitter_profile_id"
  end

  create_table "twitter_profiles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "twitter_id", null: false, unsigned: true
    t.string "screen_name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "profile_image_url", null: false
    t.string "name", null: false
    t.index ["twitter_id"], name: "index_twitter_profiles_on_twitter_id", unique: true
  end

  create_table "url_prefixes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "document_collection_id", null: false
    t.string "prefix", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["document_collection_id", "prefix"], name: "index_url_prefixes_on_document_collection_id_and_prefix", unique: true
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "persistence_token"
    t.integer "login_count", default: 0, null: false
    t.boolean "is_affiliate_admin", default: false, null: false
    t.datetime "last_request_at", precision: nil
    t.datetime "last_login_at", precision: nil
    t.datetime "current_login_at", precision: nil
    t.string "last_login_ip"
    t.string "current_login_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "contact_name"
    t.boolean "is_affiliate", default: true, null: false
    t.string "organization_name"
    t.string "api_key", limit: 32
    t.string "approval_status", null: false
    t.boolean "welcome_email_sent", default: false, null: false
    t.boolean "requires_manual_approval", default: false
    t.integer "default_affiliate_id"
    t.boolean "sees_filtered_totals", default: true, null: false
    t.string "uid"
    t.string "first_name"
    t.string "last_name"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["persistence_token"], name: "index_users_on_persistence_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "watchers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.integer "user_id"
    t.integer "affiliate_id"
    t.string "name"
    t.string "check_interval"
    t.string "throttle_period"
    t.string "conditions"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "time_window"
    t.string "query_blocklist"
  end

  create_table "youtube_playlists", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "youtube_profile_id"
    t.string "playlist_id"
    t.string "etag"
    t.text "news_item_ids", size: :long
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["youtube_profile_id", "playlist_id"], name: "index_youtube_playlists_on_youtube_profile_id_and_playlist_id", unique: true
  end

  create_table "youtube_profiles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "channel_id", null: false
    t.datetime "imported_at", precision: nil
    t.index ["channel_id"], name: "index_youtube_profiles_on_channel_id", unique: true
    t.index ["id", "imported_at"], name: "index_youtube_profiles_on_id_and_imported_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "searchgov_documents", "searchgov_urls"
  add_foreign_key "searchgov_urls", "searchgov_domains"
end
