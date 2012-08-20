# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120820173652) do

  create_table "affiliate_feature_additions", :force => true do |t|
    t.integer  "affiliate_id", :null => false
    t.integer  "feature_id",   :null => false
    t.datetime "created_at",   :null => false
  end

  add_index "affiliate_feature_additions", ["affiliate_id", "feature_id"], :name => "index_affiliate_feature_additions_on_affiliate_id_and_feature_id", :unique => true

  create_table "affiliate_templates", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "stylesheet"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "affiliates", :force => true do |t|
    t.string   "name",                                                                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_staged_content",                                              :default => false,           :null => false
    t.string   "website"
    t.boolean  "is_sayt_enabled",                                                 :default => true
    t.string   "display_name",                                                                                 :null => false
    t.string   "search_results_page_title",                                                                    :null => false
    t.string   "staged_search_results_page_title",                                                             :null => false
    t.boolean  "exclude_webtrends",                                               :default => false,           :null => false
    t.string   "external_css_url"
    t.string   "staged_external_css_url"
    t.string   "favicon_url"
    t.string   "staged_favicon_url"
    t.text     "css_properties"
    t.text     "staged_css_properties"
    t.string   "top_searches_label",                                              :default => "Search Trends"
    t.string   "theme"
    t.string   "staged_theme"
    t.string   "locale",                                                          :default => "en",            :null => false
    t.text     "scope_ids"
    t.boolean  "is_agency_govbox_enabled",                                        :default => false
    t.boolean  "is_medline_govbox_enabled",                                       :default => false
    t.text     "previous_fields_json",                      :limit => 2147483647
    t.text     "live_fields_json",                          :limit => 2147483647
    t.text     "staged_fields_json",                        :limit => 2147483647
    t.string   "results_source",                            :limit => 15,         :default => "bing+odie"
    t.text     "scope_keywords"
    t.boolean  "uses_managed_header_footer"
    t.boolean  "staged_uses_managed_header_footer"
    t.string   "header_image_file_name"
    t.string   "header_image_content_type"
    t.integer  "header_image_file_size"
    t.datetime "header_image_updated_at"
    t.string   "staged_header_image_file_name"
    t.string   "staged_header_image_content_type"
    t.integer  "staged_header_image_file_size"
    t.datetime "staged_header_image_updated_at"
    t.integer  "fetch_concurrency",                                               :default => 1,               :null => false
    t.string   "default_search_label",                      :limit => 20,                                      :null => false
    t.boolean  "is_time_filter_enabled",                                          :default => true
    t.boolean  "is_related_searches_enabled",                                     :default => true
    t.string   "left_nav_label",                            :limit => 20
    t.string   "ga_web_property_id",                        :limit => 20
    t.boolean  "show_deep_links",                                                 :default => true,            :null => false
    t.string   "page_background_image_file_name"
    t.string   "page_background_image_content_type"
    t.integer  "page_background_image_file_size"
    t.datetime "page_background_image_updated_at"
    t.string   "staged_page_background_image_file_name"
    t.string   "staged_page_background_image_content_type"
    t.integer  "staged_page_background_image_file_size"
    t.datetime "staged_page_background_image_updated_at"
    t.boolean  "is_twitter_govbox_enabled",                                       :default => false
    t.boolean  "is_odie_govbox_enabled",                                          :default => true,            :null => false
    t.boolean  "is_photo_govbox_enabled",                                         :default => false
    t.text     "dublin_core_mappings"
  end

  add_index "affiliates", ["name"], :name => "index_affiliates_on_name", :unique => true

  create_table "affiliates_form_agencies", :id => false, :force => true do |t|
    t.integer "affiliate_id",   :null => false
    t.integer "form_agency_id", :null => false
  end

  add_index "affiliates_form_agencies", ["affiliate_id", "form_agency_id"], :name => "affiliates_form_agencies_on_foreign_keys", :unique => true

  create_table "affiliates_twitter_profiles", :id => false, :force => true do |t|
    t.integer "affiliate_id",       :null => false
    t.integer "twitter_profile_id", :null => false
  end

  create_table "affiliates_users", :id => false, :force => true do |t|
    t.integer "affiliate_id"
    t.integer "user_id"
  end

  add_index "affiliates_users", ["affiliate_id", "user_id"], :name => "index_affiliates_users_on_affiliate_id_and_user_id", :unique => true
  add_index "affiliates_users", ["user_id"], :name => "index_affiliates_users_on_user_id"

  create_table "agencies", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.string   "phone",             :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.text     "name_variants"
    t.string   "toll_free_phone",   :limit => 15
    t.string   "tty_phone",         :limit => 15
    t.string   "twitter_username",  :limit => 18
    t.string   "youtube_username",  :limit => 40
    t.string   "facebook_username", :limit => 75
    t.string   "flickr_url"
  end

  create_table "agency_queries", :force => true do |t|
    t.string   "phrase"
    t.integer  "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_queries", ["phrase"], :name => "index_agency_queries_on_phrase", :unique => true

  create_table "agency_urls", :force => true do |t|
    t.integer  "agency_id"
    t.string   "url"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_urls", ["agency_id", "locale", "url"], :name => "index_agency_urls_on_agency_id_and_locale_and_url"

  create_table "auto_recalls", :force => true do |t|
    t.integer  "recall_id"
    t.string   "make",                     :limit => 25
    t.string   "model"
    t.integer  "year"
    t.string   "component_description"
    t.date     "manufacturing_begin_date"
    t.date     "manufacturing_end_date"
    t.string   "manufacturer",             :limit => 40
    t.string   "recalled_component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auto_recalls", ["recall_id"], :name => "index_auto_recalls_on_recall_id"

  create_table "boosted_contents", :force => true do |t|
    t.integer  "affiliate_id"
    t.string   "title",                                            :null => false
    t.string   "url",                                              :null => false
    t.string   "description",                                      :null => false
    t.datetime "created_at"
    t.string   "locale",           :limit => 6,                    :null => false
    t.datetime "updated_at"
    t.text     "keywords"
    t.boolean  "auto_generated",                :default => false, :null => false
    t.string   "status",                                           :null => false
    t.date     "publish_start_on",                                 :null => false
    t.date     "publish_end_on"
  end

  add_index "boosted_contents", ["affiliate_id"], :name => "index_boosted_sites_on_affiliate_id"

  create_table "catalog_prefixes", :force => true do |t|
    t.string   "prefix",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "common_substrings", :force => true do |t|
    t.integer  "indexed_domain_id",                  :null => false
    t.text     "substring",                          :null => false
    t.float    "saturation",        :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "common_substrings", ["indexed_domain_id"], :name => "index_common_substrings_on_indexed_domain_id"

  create_table "connections", :force => true do |t|
    t.integer  "affiliate_id",                                          :null => false
    t.integer  "connected_affiliate_id",                                :null => false
    t.string   "label",                  :limit => 50,                  :null => false
    t.integer  "position",                             :default => 100, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["affiliate_id"], :name => "index_connections_on_affiliate_id"

  create_table "daily_left_nav_stats", :force => true do |t|
    t.integer "affiliate_id",                :null => false
    t.date    "day",                         :null => false
    t.string  "search_type",                 :null => false
    t.string  "params"
    t.integer "total",        :default => 0, :null => false
  end

  add_index "daily_left_nav_stats", ["affiliate_id", "day"], :name => "index_daily_left_nav_stats_on_affiliate_id_and_day"

  create_table "daily_query_noresults_stats", :force => true do |t|
    t.date    "day",       :null => false
    t.string  "affiliate", :null => false
    t.string  "query",     :null => false
    t.integer "times",     :null => false
  end

  add_index "daily_query_noresults_stats", ["affiliate", "day"], :name => "index_daily_query_noresults_stats_on_affiliate_and_day"

  create_table "daily_query_stats", :force => true do |t|
    t.date    "day",                                                   :null => false
    t.string  "query",     :limit => 100,                              :null => false
    t.integer "times",                                                 :null => false
    t.string  "affiliate", :limit => 32,  :default => "usasearch.gov"
    t.string  "locale",    :limit => 5,   :default => "en"
  end

  add_index "daily_query_stats", ["affiliate", "day"], :name => "ad"
  add_index "daily_query_stats", ["day", "affiliate"], :name => "da"
  add_index "daily_query_stats", ["query", "day"], :name => "qd"

  create_table "daily_search_module_stats", :force => true do |t|
    t.date    "day",            :null => false
    t.string  "affiliate_name", :null => false
    t.string  "module_tag",     :null => false
    t.string  "vertical",       :null => false
    t.string  "locale",         :null => false
    t.integer "impressions",    :null => false
    t.integer "clicks",         :null => false
  end

  add_index "daily_search_module_stats", ["module_tag", "day"], :name => "index_daily_search_module_stats_on_module_tag_and_day"

  create_table "daily_usage_stats", :force => true do |t|
    t.date    "day"
    t.integer "total_queries"
    t.string  "affiliate",     :limit => 32, :default => "usasearch.gov"
  end

  add_index "daily_usage_stats", ["affiliate", "day"], :name => "index_daily_usage_stats_on_affiliate_and_day", :unique => true
  add_index "daily_usage_stats", ["day", "affiliate"], :name => "index_daily_usage_stats_on_day_and_affiliate", :unique => true

  create_table "document_collections", :force => true do |t|
    t.integer  "affiliate_id", :null => false
    t.string   "name",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_collections", ["affiliate_id", "name"], :name => "index_document_collections_on_affiliate_id_and_name", :unique => true

  create_table "email_templates", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
  end

  create_table "excluded_domains", :force => true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "excluded_urls", :force => true do |t|
    t.text     "url"
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "excluded_urls", ["affiliate_id"], :name => "index_excluded_urls_on_affiliate_id"

  create_table "facebook_profiles", :force => true do |t|
    t.string   "username"
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_profiles", ["affiliate_id"], :name => "index_facebook_profiles_on_affiliate_id"

  create_table "faqs", :force => true do |t|
    t.string   "url"
    t.text     "question"
    t.text     "answer"
    t.integer  "ranking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",     :limit => 5, :default => "en"
  end

  create_table "featured_collection_keywords", :force => true do |t|
    t.integer  "featured_collection_id", :null => false
    t.string   "value",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_collection_keywords", ["featured_collection_id"], :name => "index_featured_collection_keywords_on_featured_collection_id"

  create_table "featured_collection_links", :force => true do |t|
    t.integer  "featured_collection_id", :null => false
    t.integer  "position",               :null => false
    t.string   "title",                  :null => false
    t.string   "url",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_collection_links", ["featured_collection_id"], :name => "index_featured_collection_links_on_featured_collection_id"

  create_table "featured_collections", :force => true do |t|
    t.integer  "affiliate_id"
    t.string   "title",                 :null => false
    t.string   "title_url"
    t.string   "locale",                :null => false
    t.string   "status",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "publish_start_on",      :null => false
    t.date     "publish_end_on"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_alt_text"
    t.string   "image_attribution"
    t.string   "image_attribution_url"
    t.string   "layout",                :null => false
  end

  add_index "featured_collections", ["affiliate_id"], :name => "index_featured_collections_on_affiliate_id"

  create_table "features", :force => true do |t|
    t.string   "internal_name", :null => false
    t.string   "display_name",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "features", ["internal_name"], :name => "index_features_on_internal_name"

  create_table "flickr_photos", :force => true do |t|
    t.boolean  "is_public"
    t.integer  "farm"
    t.string   "title"
    t.string   "flickr_id"
    t.string   "server"
    t.boolean  "is_family"
    t.string   "secret"
    t.string   "owner"
    t.boolean  "is_friend"
    t.string   "last_update",       :limit => 15
    t.string   "url_sq"
    t.string   "url_t"
    t.string   "url_s"
    t.string   "url_q"
    t.string   "url_m"
    t.string   "url_n"
    t.string   "url_z"
    t.string   "url_c"
    t.string   "url_l"
    t.string   "url_o"
    t.integer  "width_sq"
    t.integer  "width_t"
    t.integer  "width_s"
    t.integer  "width_q"
    t.integer  "width_m"
    t.integer  "width_n"
    t.integer  "width_z"
    t.integer  "width_c"
    t.integer  "width_l"
    t.integer  "width_o"
    t.integer  "height_sq"
    t.integer  "height_t"
    t.integer  "height_s"
    t.integer  "height_q"
    t.integer  "height_m"
    t.integer  "height_n"
    t.integer  "height_z"
    t.integer  "height_c"
    t.integer  "height_l"
    t.integer  "height_o"
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "accuracy"
    t.integer  "license",           :limit => 3
    t.text     "tags"
    t.text     "machine_tags"
    t.datetime "date_taken"
    t.datetime "date_upload"
    t.string   "path_alias",        :limit => 50
    t.string   "owner_name",        :limit => 50
    t.string   "icon_server",       :limit => 10
    t.integer  "icon_farm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flickr_profile_id"
  end

  create_table "flickr_profiles", :force => true do |t|
    t.string   "url"
    t.string   "profile_type"
    t.string   "profile_id"
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flickr_profiles", ["affiliate_id"], :name => "index_flickr_profiles_on_affiliate_id"

  create_table "food_recalls", :force => true do |t|
    t.integer  "recall_id"
    t.string   "summary",                   :null => false
    t.text     "description",               :null => false
    t.string   "url",                       :null => false
    t.string   "food_type",   :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "food_recalls", ["recall_id"], :name => "index_food_recalls_on_recall_id"

  create_table "form_agencies", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "locale",       :null => false
    t.string   "display_name", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "forms", :force => true do |t|
    t.string   "number",         :null => false
    t.string   "url",            :null => false
    t.string   "file_type",      :null => false
    t.text     "details"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "form_agency_id", :null => false
  end

  add_index "forms", ["form_agency_id"], :name => "index_forms_on_form_agency_id"

  create_table "gov_forms", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "form_number", :null => false
    t.string   "agency",      :null => false
    t.string   "bureau"
    t.text     "description"
    t.string   "url",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "help_links", :force => true do |t|
    t.string   "action_name"
    t.string   "help_page_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "help_links", ["action_name"], :name => "index_help_links_on_action_name"

  create_table "image_search_labels", :force => true do |t|
    t.integer  "affiliate_id", :null => false
    t.string   "name",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "image_search_labels", ["affiliate_id"], :name => "index_image_search_labels_on_affiliate_id", :unique => true

  create_table "indexed_documents", :force => true do |t|
    t.text     "title"
    t.text     "description"
    t.string   "url",               :limit => 2000
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body",              :limit => 2147483647
    t.string   "doctype",           :limit => 10
    t.datetime "last_crawled_at"
    t.string   "last_crawl_status"
    t.string   "content_hash",      :limit => 32
    t.integer  "indexed_domain_id"
    t.integer  "load_time"
  end

  add_index "indexed_documents", ["affiliate_id", "content_hash"], :name => "index_indexed_documents_on_affiliate_id_and_content_hash", :unique => true
  add_index "indexed_documents", ["affiliate_id", "id"], :name => "index_indexed_documents_on_affiliate_id_and_id", :unique => true
  add_index "indexed_documents", ["affiliate_id", "url"], :name => "by_aid_url", :length => {"affiliate_id"=>nil, "url"=>50}
  add_index "indexed_documents", ["indexed_domain_id"], :name => "index_indexed_documents_on_indexed_domain_id"

  create_table "indexed_domains", :force => true do |t|
    t.integer "affiliate_id", :null => false
    t.string  "domain",       :null => false
  end

  add_index "indexed_domains", ["affiliate_id", "domain"], :name => "index_indexed_domains_on_affiliate_id_and_domain", :unique => true
  add_index "indexed_domains", ["domain"], :name => "index_indexed_domains_on_domain"

  create_table "logfile_blocked_class_cs", :force => true do |t|
    t.string   "classc",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logfile_blocked_class_cs", ["classc"], :name => "index_logfile_blocked_class_cs_on_classc", :unique => true

  create_table "logfile_blocked_ips", :force => true do |t|
    t.string   "ip",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logfile_blocked_ips", ["ip"], :name => "index_logfile_blocked_ips_on_ip", :unique => true

  create_table "logfile_blocked_queries", :force => true do |t|
    t.string   "query",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logfile_blocked_queries", ["query"], :name => "index_logfile_blocked_queries_on_query", :unique => true

  create_table "logfile_blocked_regexps", :force => true do |t|
    t.string   "regexp",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logfile_blocked_regexps", ["regexp"], :name => "index_logfile_blocked_regexps_on_regexp", :unique => true

  create_table "logfile_blocked_user_agents", :force => true do |t|
    t.string   "agent",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logfile_whitelisted_class_cs", :force => true do |t|
    t.string   "classc",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "med_groups", :force => true do |t|
    t.integer  "medline_gid"
    t.string   "medline_title",                                  :null => false
    t.string   "medline_url",   :limit => 120
    t.string   "locale",        :limit => 5,   :default => "en"
    t.boolean  "visible",                      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "med_groups", ["medline_gid"], :name => "index_med_groups_on_medline_gid"
  add_index "med_groups", ["medline_title"], :name => "index_med_groups_on_medline_title"

  create_table "med_related_topics", :force => true do |t|
    t.integer  "med_topic_id",        :null => false
    t.integer  "related_medline_tid", :null => false
    t.string   "title",               :null => false
    t.string   "url",                 :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "med_related_topics", ["med_topic_id"], :name => "index_med_related_topics_on_med_topic_id"

  create_table "med_sites", :force => true do |t|
    t.integer  "med_topic_id", :null => false
    t.string   "title",        :null => false
    t.string   "url",          :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "med_sites", ["med_topic_id"], :name => "index_med_sites_on_med_topic_id"

  create_table "med_synonyms", :force => true do |t|
    t.string   "medline_title", :null => false
    t.integer  "topic_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "med_synonyms", ["medline_title"], :name => "index_med_synonyms_on_medline_title"

  create_table "med_topic_groups", :force => true do |t|
    t.integer  "topic_id",   :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "med_topic_relateds", :force => true do |t|
    t.integer  "topic_id",         :null => false
    t.integer  "related_topic_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "med_topics", :force => true do |t|
    t.integer  "medline_tid"
    t.string   "medline_title",                                         :null => false
    t.string   "medline_url",          :limit => 120
    t.string   "locale",               :limit => 5,   :default => "en"
    t.integer  "lang_mapped_topic_id"
    t.text     "summary_html"
    t.boolean  "visible",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mesh_titles",                         :default => ""
  end

  add_index "med_topics", ["medline_tid"], :name => "index_med_topics_on_medline_tid"
  add_index "med_topics", ["medline_title"], :name => "index_med_topics_on_medline_title"

  create_table "misspellings", :force => true do |t|
    t.string   "wrong"
    t.string   "rite"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "misspellings", ["wrong"], :name => "index_misspellings_on_wrong"

  create_table "navigations", :force => true do |t|
    t.integer  "affiliate_id",                      :null => false
    t.integer  "navigable_id",                      :null => false
    t.string   "navigable_type",                    :null => false
    t.integer  "position",       :default => 100,   :null => false
    t.boolean  "is_active",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "navigations", ["affiliate_id"], :name => "index_navigations_on_affiliate_id"

  create_table "news_items", :force => true do |t|
    t.integer  "rss_feed_id",     :null => false
    t.string   "link",            :null => false
    t.string   "title",           :null => false
    t.string   "guid",            :null => false
    t.text     "description"
    t.datetime "published_at",    :null => false
    t.datetime "created_at"
    t.integer  "rss_feed_url_id", :null => false
    t.datetime "updated_at"
    t.string   "contributor"
    t.string   "subject"
    t.string   "publisher"
  end

  add_index "news_items", ["link"], :name => "index_news_items_on_link"
  add_index "news_items", ["rss_feed_id", "guid"], :name => "index_news_items_on_rss_feed_id_and_guid"
  add_index "news_items", ["rss_feed_url_id"], :name => "index_news_items_on_rss_feed_url_id"

  create_table "recall_details", :force => true do |t|
    t.integer  "recall_id"
    t.string   "detail_type"
    t.string   "detail_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recall_details", ["recall_id"], :name => "index_recall_details_on_recall_id"

  create_table "recalls", :force => true do |t|
    t.string   "recall_number", :limit => 10
    t.integer  "y2k"
    t.date     "recalled_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "organization",  :limit => 10
  end

  add_index "recalls", ["recall_number"], :name => "index_recalls_on_recall_number"

  create_table "report_recipients", :force => true do |t|
    t.string   "email",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "robots", :force => true do |t|
    t.string   "domain",     :null => false
    t.text     "prefixes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "robots", ["domain"], :name => "index_robots_on_domain"

  create_table "rss_feed_urls", :force => true do |t|
    t.integer  "rss_feed_id",                              :null => false
    t.string   "url",                                      :null => false
    t.datetime "last_crawled_at"
    t.string   "last_crawl_status", :default => "Pending", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rss_feed_urls", ["rss_feed_id"], :name => "index_rss_feed_urls_on_rss_feed_id"

  create_table "rss_feeds", :force => true do |t|
    t.integer  "affiliate_id",                       :null => false
    t.string   "name",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "shown_in_govbox", :default => false, :null => false
    t.boolean  "is_managed",      :default => false, :null => false
    t.boolean  "is_video",        :default => false, :null => false
  end

  add_index "rss_feeds", ["affiliate_id"], :name => "index_rss_feeds_on_affiliate_id"

  create_table "sayt_filters", :force => true do |t|
    t.string   "phrase",                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "always_filtered",          :default => false, :null => false
    t.boolean  "filter_only_exact_phrase", :default => false, :null => false
  end

  add_index "sayt_filters", ["always_filtered"], :name => "index_sayt_filters_on_always_filtered"
  add_index "sayt_filters", ["phrase"], :name => "index_sayt_filters_on_phrase", :unique => true

  create_table "sayt_suggestions", :force => true do |t|
    t.string   "phrase",                          :null => false
    t.datetime "created_at"
    t.integer  "popularity",   :default => 1,     :null => false
    t.datetime "updated_at"
    t.integer  "affiliate_id"
    t.boolean  "is_protected", :default => false
    t.datetime "deleted_at"
  end

  add_index "sayt_suggestions", ["affiliate_id", "phrase"], :name => "index_sayt_suggestions_on_affiliate_id_and_phrase", :unique => true

  create_table "search_modules", :force => true do |t|
    t.string   "tag",          :null => false
    t.string   "display_name", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_modules", ["tag"], :name => "index_search_modules_on_tag", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_domains", :force => true do |t|
    t.integer  "affiliate_id", :null => false
    t.string   "site_name",    :null => false
    t.string   "domain",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_domains", ["affiliate_id", "domain"], :name => "index_site_domains_on_affiliate_id_and_domain", :unique => true

  create_table "site_pages", :force => true do |t|
    t.string   "url_slug"
    t.string   "title"
    t.string   "breadcrumb",   :limit => 2048
    t.text     "main_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_pages", ["url_slug"], :name => "index_site_pages_on_url_slug", :unique => true

  create_table "sitemaps", :force => true do |t|
    t.string   "url"
    t.integer  "affiliate_id"
    t.datetime "last_crawled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sitemaps", ["affiliate_id"], :name => "index_sitemaps_on_affiliate_id"

  create_table "superfresh_urls", :force => true do |t|
    t.text     "url"
    t.datetime "crawled_at"
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "superfresh_urls", ["affiliate_id"], :name => "index_superfresh_urls_on_affiliate_id"

  create_table "top_searches", :force => true do |t|
    t.string   "query"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "affiliate_id"
  end

  add_index "top_searches", ["affiliate_id"], :name => "index_top_searches_on_affiliate_id"
  add_index "top_searches", ["position", "affiliate_id"], :name => "index_top_searches_on_position_and_affiliate_id", :unique => true

  create_table "tweets", :force => true do |t|
    t.integer  "tweet_id",           :limit => 8
    t.string   "tweet_text"
    t.integer  "twitter_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
  end

  add_index "tweets", ["twitter_profile_id"], :name => "index_tweets_on_twitter_profile_id"

  create_table "twitter_profiles", :force => true do |t|
    t.integer  "twitter_id"
    t.string   "screen_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_image_url", :null => false
    t.string   "name",              :null => false
  end

  add_index "twitter_profiles", ["twitter_id"], :name => "index_twitter_profiles_on_twitter_id"

  create_table "url_prefixes", :force => true do |t|
    t.integer  "document_collection_id", :null => false
    t.string   "prefix",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "url_prefixes", ["document_collection_id", "prefix"], :name => "index_url_prefixes_on_document_collection_id_and_prefix", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                                                            :null => false
    t.string   "perishable_token"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",                            :default => 0,                            :null => false
    t.string   "time_zone",                              :default => "Eastern Time (US & Canada)", :null => false
    t.boolean  "is_affiliate_admin",                     :default => false,                        :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.boolean  "is_affiliate",                           :default => true,                         :null => false
    t.string   "phone"
    t.string   "organization_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "api_key",                  :limit => 32
    t.string   "approval_status",                                                                  :null => false
    t.string   "email_verification_token"
    t.boolean  "welcome_email_sent",                     :default => false,                        :null => false
    t.boolean  "requires_manual_approval",               :default => false
    t.text     "notes"
  end

  add_index "users", ["api_key"], :name => "index_users_on_api_key", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  create_table "youtube_profiles", :force => true do |t|
    t.string   "username"
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "youtube_profiles", ["affiliate_id"], :name => "index_youtube_profiles_on_affiliate_id"

end
