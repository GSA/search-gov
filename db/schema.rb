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

ActiveRecord::Schema.define(:version => 20110715175201) do

  create_table "affiliate_broadcasts", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "subject",    :null => false
    t.text     "body",       :null => false
    t.datetime "created_at"
  end

  add_index "affiliate_broadcasts", ["user_id"], :name => "index_affiliate_broadcasts_on_user_id"

  create_table "affiliate_templates", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "stylesheet"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "affiliates", :force => true do |t|
    t.string   "name",                                                                            :null => false
    t.text     "domains"
    t.text     "header"
    t.text     "footer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "staged_domains"
    t.text     "staged_header"
    t.text     "staged_footer"
    t.boolean  "has_staged_content",                             :default => false,               :null => false
    t.string   "website"
    t.integer  "affiliate_template_id"
    t.boolean  "is_sayt_enabled",                                :default => true
    t.boolean  "is_affiliate_suggestions_enabled",               :default => true
    t.string   "related_topics_setting",           :limit => 30, :default => "affiliate_enabled"
    t.integer  "staged_affiliate_template_id"
    t.string   "display_name",                                                                    :null => false
    t.string   "search_results_page_title",                                                       :null => false
    t.string   "staged_search_results_page_title",                                                :null => false
  end

  add_index "affiliates", ["affiliate_template_id"], :name => "index_affiliates_on_affiliate_template_id"
  add_index "affiliates", ["name"], :name => "index_affiliates_on_name", :unique => true

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

  create_table "agency_popular_urls", :force => true do |t|
    t.integer "agency_id", :null => false
    t.string  "url",       :null => false
    t.integer "rank",      :null => false
    t.string  "title",     :null => false
  end

  add_index "agency_popular_urls", ["agency_id"], :name => "index_agency_popular_urls_on_agency_id"

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
    t.string   "title",                                       :null => false
    t.string   "url",                                         :null => false
    t.string   "description",                                 :null => false
    t.datetime "created_at"
    t.string   "locale",       :limit => 6, :default => "en", :null => false
    t.datetime "updated_at"
    t.text     "keywords"
  end

  add_index "boosted_contents", ["affiliate_id"], :name => "index_boosted_sites_on_affiliate_id"

  create_table "calais_related_searches", :force => true do |t|
    t.string   "term"
    t.string   "related_terms",  :limit => 4096
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",                         :default => "en",  :null => false
    t.integer  "affiliate_id"
    t.boolean  "gets_refreshed",                 :default => false, :null => false
  end

  add_index "calais_related_searches", ["affiliate_id", "term"], :name => "index_calais_related_searches_on_affiliate_id_and_term"

  create_table "clicks", :force => true do |t|
    t.string   "query"
    t.datetime "queried_at"
    t.string   "url"
    t.integer  "serp_position"
    t.string   "affiliate",      :limit => 50
    t.datetime "clicked_at"
    t.string   "results_source"
    t.string   "user_agent"
    t.string   "click_ip"
  end

  add_index "clicks", ["clicked_at"], :name => "index_clicks_on_clicked_at"
  add_index "clicks", ["results_source", "clicked_at"], :name => "index_clicks_on_results_source_and_clicked_at"

  create_table "daily_contextual_query_totals", :force => true do |t|
    t.date     "day"
    t.integer  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_contextual_query_totals", ["day"], :name => "index_daily_contextual_query_totals_on_day", :unique => true

  create_table "daily_popular_queries", :force => true do |t|
    t.date     "day"
    t.integer  "affiliate_id"
    t.string   "locale",       :limit => 5
    t.string   "query"
    t.integer  "times"
    t.boolean  "is_grouped",                :default => false
    t.integer  "time_frame"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_popular_queries", ["day", "affiliate_id", "locale", "is_grouped", "time_frame"], :name => "dalit_index"

  create_table "daily_query_noresults_stats", :force => true do |t|
    t.date    "day",       :null => false
    t.string  "affiliate", :null => false
    t.string  "locale",    :null => false
    t.string  "query",     :null => false
    t.integer "times",     :null => false
  end

  add_index "daily_query_noresults_stats", ["day", "affiliate", "locale", "query"], :name => "dalq", :unique => true

  create_table "daily_query_stats", :force => true do |t|
    t.date    "day",                                                   :null => false
    t.string  "query",     :limit => 100,                              :null => false
    t.integer "times",                                                 :null => false
    t.string  "affiliate", :limit => 32,  :default => "usasearch.gov"
    t.string  "locale",    :limit => 5,   :default => "en"
  end

  add_index "daily_query_stats", ["affiliate", "locale", "day", "query"], :name => "aldq", :unique => true
  add_index "daily_query_stats", ["day", "query"], :name => "dq"
  add_index "daily_query_stats", ["query", "day", "affiliate", "locale"], :name => "qdal", :unique => true

  create_table "daily_search_module_stats", :force => true do |t|
    t.date    "day",            :null => false
    t.string  "affiliate_name", :null => false
    t.string  "module_tag",     :null => false
    t.string  "vertical",       :null => false
    t.string  "locale",         :null => false
    t.integer "impressions",    :null => false
    t.integer "clicks",         :null => false
  end

  add_index "daily_search_module_stats", ["day", "affiliate_name", "module_tag", "vertical", "locale"], :name => "dics_unique", :unique => true
  add_index "daily_search_module_stats", ["day", "module_tag"], :name => "day_module"

  create_table "daily_usage_stats", :force => true do |t|
    t.date     "day"
    t.string   "profile"
    t.integer  "total_queries"
    t.integer  "total_page_views"
    t.integer  "total_unique_visitors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "affiliate",             :limit => 32, :default => "usasearch.gov"
  end

  add_index "daily_usage_stats", ["affiliate", "profile", "day"], :name => "apd", :unique => true
  add_index "daily_usage_stats", ["day", "profile", "affiliate"], :name => "index_daily_usage_stats_on_day_and_profile_and_affiliate", :unique => true

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
    t.string   "title",            :null => false
    t.string   "title_url"
    t.string   "locale",           :null => false
    t.datetime "publish_start_at"
    t.datetime "publish_end_at"
    t.string   "status",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_collections", ["affiliate_id"], :name => "index_featured_collections_on_affiliate_id"

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

  create_table "grouped_queries", :force => true do |t|
    t.string   "query",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grouped_queries", ["query"], :name => "index_grouped_queries_on_query", :unique => true

  create_table "grouped_queries_query_groups", :id => false, :force => true do |t|
    t.integer "query_group_id",   :null => false
    t.integer "grouped_query_id", :null => false
  end

  add_index "grouped_queries_query_groups", ["query_group_id", "grouped_query_id"], :name => "joinindex", :unique => true

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

  create_table "monthly_click_totals", :force => true do |t|
    t.integer  "year"
    t.integer  "month"
    t.string   "source"
    t.integer  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "monthly_click_totals", ["year", "month"], :name => "index_monthly_click_totals_on_year_and_month"

  create_table "monthly_popular_queries", :force => true do |t|
    t.integer  "year"
    t.integer  "month"
    t.string   "query"
    t.integer  "times"
    t.boolean  "is_grouped", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "monthly_popular_queries", ["year", "month", "is_grouped"], :name => "index_monthly_popular_queries_on_year_and_month_and_is_grouped"

  create_table "moving_queries", :force => true do |t|
    t.date    "day",                    :null => false
    t.integer "times",                  :null => false
    t.string  "query",   :limit => 100, :null => false
    t.float   "mean",                   :null => false
    t.float   "std_dev",                :null => false
  end

  add_index "moving_queries", ["day", "times"], :name => "index_moving_queries_on_day_and_times"

  create_table "popular_image_queries", :force => true do |t|
    t.string   "query"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "popular_image_queries", ["query"], :name => "index_popular_image_queries_on_query", :unique => true

  create_table "popular_urls", :force => true do |t|
    t.integer  "affiliate_id", :null => false
    t.string   "title",        :null => false
    t.string   "url",          :null => false
    t.integer  "rank",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "popular_urls", ["affiliate_id"], :name => "index_popular_urls_on_affiliate_id"

  create_table "query_groups", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "query_groups", ["name"], :name => "index_query_groups_on_name", :unique => true

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

  add_index "sayt_suggestions", ["affiliate_id", "phrase", "deleted_at", "popularity"], :name => "index_sayt_suggestions_on_aff_id_phrase_del_at_pop", :unique => true

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

  create_table "site_pages", :force => true do |t|
    t.string   "url_slug"
    t.string   "title"
    t.string   "breadcrumb",   :limit => 2048
    t.text     "main_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_pages", ["url_slug"], :name => "index_site_pages_on_url_slug", :unique => true

  create_table "spotlight_keywords", :force => true do |t|
    t.integer  "spotlight_id", :null => false
    t.string   "name",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spotlight_keywords", ["spotlight_id"], :name => "index_spotlight_keywords_on_spotlight_id"

  create_table "spotlights", :force => true do |t|
    t.string   "title",                          :null => false
    t.string   "notes"
    t.text     "html",                           :null => false
    t.boolean  "is_active",    :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "affiliate_id"
  end

  create_table "superfresh_urls", :force => true do |t|
    t.text     "url"
    t.datetime "crawled_at"
    t.integer  "affiliate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "superfresh_urls", ["affiliate_id"], :name => "index_superfresh_urls_on_affiliate_id"

  create_table "top_forms", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.integer  "column_number"
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "top_forms", ["column_number"], :name => "index_top_forms_on_column_number"
  add_index "top_forms", ["sort_order"], :name => "index_top_forms_on_sort_order"

  create_table "top_searches", :force => true do |t|
    t.string   "query"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "top_searches", ["position"], :name => "index_top_searches_on_position", :unique => true

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
    t.boolean  "is_analyst",                             :default => false,                        :null => false
    t.string   "phone"
    t.string   "organization_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "is_analyst_admin",                       :default => false,                        :null => false
    t.string   "api_key",                  :limit => 32
    t.string   "approval_status",                                                                  :null => false
    t.string   "email_verification_token"
    t.boolean  "welcome_email_sent",                     :default => false,                        :null => false
    t.boolean  "requires_manual_approval",               :default => false
  end

  add_index "users", ["api_key"], :name => "index_users_on_api_key", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
