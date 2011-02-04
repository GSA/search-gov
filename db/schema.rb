# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110204200027) do

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
    t.integer  "owner_id"
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
  end

  add_index "affiliates", ["affiliate_template_id"], :name => "index_affiliates_on_affiliate_template_id"
  add_index "affiliates", ["name"], :name => "index_affiliates_on_name", :unique => true
  add_index "affiliates", ["owner_id"], :name => "index_affiliates_on_user_id"

  create_table "affiliates_users", :id => false, :force => true do |t|
    t.integer "affiliate_id"
    t.integer "user_id"
  end

  add_index "affiliates_users", ["affiliate_id", "user_id"], :name => "index_affiliates_users_on_affiliate_id_and_user_id", :unique => true
  add_index "affiliates_users", ["user_id"], :name => "index_affiliates_users_on_user_id"

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

  create_table "food_recalls", :force => true do |t|
    t.integer "recall_id"
    t.string  "summary",                   :null => false
    t.text    "description",               :null => false
    t.string  "url",                       :null => false
    t.string  "food_type",   :limit => 10
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

  create_table "misspellings", :force => true do |t|
    t.string   "wrong"
    t.string   "rite"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "misspellings", ["wrong"], :name => "index_misspellings_on_wrong"

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
    t.string   "phrase",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "sayt_suggestions", ["affiliate_id", "phrase", "popularity"], :name => "index_sayt_suggestions_on_affiliate_id_and_phrase_and_popularity", :unique => true

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
    t.string   "title",                        :null => false
    t.string   "notes"
    t.text     "html",                         :null => false
    t.boolean  "is_active",  :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "email",                                                                      :null => false
    t.string   "perishable_token"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",                      :default => 0,                            :null => false
    t.string   "time_zone",                        :default => "Eastern Time (US & Canada)", :null => false
    t.boolean  "is_affiliate_admin",               :default => false,                        :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.boolean  "is_affiliate",                     :default => true,                         :null => false
    t.boolean  "is_analyst",                       :default => false,                        :null => false
    t.string   "phone"
    t.string   "organization_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "is_analyst_admin",                 :default => false,                        :null => false
    t.string   "api_key",            :limit => 32
  end

  add_index "users", ["api_key"], :name => "index_users_on_api_key", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
