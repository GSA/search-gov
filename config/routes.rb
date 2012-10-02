UsasearchRails3::Application.routes.draw do
  resource :account, :controller => "users"
  resources :users, :except => [:new]
  resource :user_session
  resources :password_resets
  resources :email_verification, :only => :show
  resources :complete_registration, :only => [:edit, :update]
  resources :affiliates, :controller => "affiliates/home" do
    member do
      post :push_content_for
      get :embed_code
      get :edit_site_information
      put :update_site_information
      get :edit_look_and_feel
      put :update_look_and_feel
      get :edit_header_footer
      put :update_header_footer
      get :preview
      post :cancel_staged_changes_for
      get :best_bets
      get :urls_and_sitemaps
      get :hosted_sitemaps
      get :content_sources
      put :create_content_sources
      get :get_the_code
      get :edit_sidebar
      put :update_sidebar
      get :edit_results_modules
      put :update_results_modules
      get :edit_external_tracking
      put :update_external_tracking
      get :new_connection_fields
    end
    collection do
      get :home
      put :update_contact_information
      get :new_site_domain_fields
      get :new_sitemap_fields
      get :new_rss_feed_fields
      get :new_managed_header_link_fields
      get :new_managed_footer_link_fields
      get '/demo' => redirect(BLOG_URL, :status => 302)
      get '/how_it_works' => redirect(BLOG_URL, :status => 302)
    end
    resources :users, :controller => 'affiliates/users', :only => [:index, :new, :create, :destroy]
    resources :boosted_contents, :controller => "affiliates/boosted_contents" do
      collection do
        delete :destroy_all
        get :bulk_new
        post :bulk
      end
    end
    resources :on_demand_urls, :controller => 'affiliates/on_demand_urls', :only => [:new, :create, :destroy] do
      collection do
        post :upload
        get :crawled
        get :uncrawled
        get :bulk_new
        get :export_crawled, :constraints => { :format => 'csv' }
      end
    end
    resources :type_ahead_search, :controller => "affiliates/sayt", :as => "type_ahead_search" do
      collection do
        post :upload
        post :preferences
        get :demo
        delete :destroy_all
      end
    end
    resources :analytics, :controller => "affiliates/analytics", :only => [:index] do
      collection do
        get :monthly_reports
        get :query_search
        get :left_nav_usage
      end
    end
    resources :related_topics, :controller => "affiliates/related_topics" do
      collection do
        post :preferences
      end
    end
    resources :api, :controller => "affiliates/api"
    resources :featured_collections, :controller => "affiliates/featured_collections"
    resources :rss_feeds, :controller => "affiliates/rss_feeds" do
      collection do
        get :new_url_fields
      end
    end
    resources :document_collections, :controller => "affiliates/document_collections"
    resources :excluded_urls, :controller => "affiliates/excluded_urls", :only => [:index, :create, :destroy]
    resources :sitemaps, :controller => "affiliates/sitemaps", :only => [:index, :new, :create, :destroy]
    resources :top_searches, :controller => "affiliates/top_searches", :only => [:index, :create]
    resources :site_domains, :controller => "affiliates/site_domains" do
      collection do
        get :bulk_new
        post :upload
      end
    end

    resources :social_media, :controller => 'affiliates/social_media', :only => [:index, :create, :destroy] do
      member do
        get :preview
      end
      collection do
        get :new_profile_fields
      end
    end
  end
  get '/search' => 'searches#index', :as => :search
  get '/search/advanced' => 'searches#advanced', :as => :advanced_search
  get '/search/images' => 'image_searches#index', :as => :image_search
  get '/images' => 'images#index', :as => :images
  resources :recalls, :only => [:index]
  get '/recalls/index.xml' => 'recalls#index', :defaults => { :format => 'rss' }
  get '/search/recalls' => 'recalls#search', :as => :recalls_search
  resources :forms, :only => :index
  namespace :api do
    namespace :v1 do
      resources :form_agencies, :only => [:show, :index], :defaults => { :format => 'json' }
      resources :forms, :only => [:show], :defaults => { :format => 'json' } do
        get :search, :on => :collection
      end
    end
  end
  get '/search/docs' => 'searches#docs', :as => :docs_search
  get '/search/news' => 'searches#news', :as => :news_search
  get '/search/news/videos' => 'searches#video_news', :as => :video_news_search
  resources :image_searches
  namespace :admin do
    resources :affiliates do as_routes end
    resources :affiliate_templates do as_routes end
    resources :users do as_routes end
    resources :sayt_filters do as_routes end
    resources :sayt_suggestions do as_routes end
    resources :misspellings do as_routes end
    resources :affiliate_boosted_contents do as_routes end
    resources :document_collections do as_routes end
    resources :url_prefixes do as_routes end
    resources :catalog_prefixes do as_routes end
    resources :gov_forms do as_routes end
    resources :top_forms, :only => [:index, :create, :update, :destroy]
    resources :superfresh_urls do as_routes end
    resources :superfresh_urls_bulk_upload, :only => :index do
      collection do
        post :upload
      end
    end
    resources :site_pages do as_routes end
    resources :agencies do as_routes end
    resources :agency_urls do as_routes end
    resources :agency_queries do as_routes end
    resources :logfile_blocked_queries do as_routes end
    resources :logfile_blocked_ips do as_routes end
    resources :logfile_blocked_class_cs do as_routes end
    resources :logfile_whitelisted_class_cs do as_routes end
    resources :logfile_blocked_regexps do as_routes end
    resources :logfile_blocked_user_agents do as_routes end
    resources :report_recipients do as_routes end
    resources :search_modules do as_routes end
    resources :excluded_domains do as_routes end
    resources :affiliate_scopes do as_routes end
    resources :site_domains do as_routes end
    resources :sitemaps do as_routes end
    resources :features do as_routes end
    resources :affiliate_feature_additions do as_routes end
    resources :help_links do as_routes end
    resources :search_module_stats, :only => :index
    resources :monthly_reports, :only => :index
    resources :affiliate_reports, :only => :index
    resources :email_templates do as_routes end
    resources :common_substrings do as_routes end
    resources :compare_search_results, :only => :index
    resources :form_agencies do as_routes end
    resources :forms do as_routes end
    resources :bing_urls do as_routes end
  end
  match '/admin/search_module_stats' => 'admin/search_module_stats#index', :as => :admin_search_module_stats
  match '/admin/affiliates/:id/analytics' => 'admin/affiliates#analytics', :as => :affiliate_analytics_redirect
  match '/admin/site_domains/:id/trigger_crawl' => 'admin/site_domains#trigger_crawl', :as => :site_domain_trigger_crawl
  match '/admin' => 'admin/home#index', :as => :admin_home_page

  match 'affiliates/:id/analytics/timeline/(:query)' => 'affiliates/timeline#show', :as => :affiliate_query_timeline, :constraints => { :query => /.*/ }
  get '/' => 'home#index', :as => :home_page
  match '/contact_form' => 'home#contact_form', :as => :contact_form
  get '/searches/auto_complete_for_search_query' => 'searches#auto_complete_for_search_query', :as => 'auto_complete_for_search_query'
  get '/widgets/trending_searches' => 'widgets#trending_searches', :as => :trending_searches_widget
  get '/superfresh' => 'superfresh#index', :as => :main_superfresh_feed
  get '/superfresh/:feed_id' => 'superfresh#index', :as => :superfresh_feed
  get '/usasearch_hosted_sitemap/:id.xml' => 'hosted_sitemap#show', :as => :hosted_sitemap
  get '/usa/:url_slug' => 'usa#show', :as => :usa, :constraints => { :url_slug => /.*/ }
  get '/usa/' => 'home#index', :as => :usa_mobile_home_redirect
  get '/api/search' => 'api#search', :as => :api_search
  get '/user/developer_redirect' => 'users#developer_redirect', :as => :developer_redirect
  get '/login' => 'user_sessions#new', :as => :login
  get "/sayt" => "sayt#index"
  get "/clicked" => "clicked#index"
  get "/embedded_search" => "embedded_searches#index"
  get '/program' => redirect(BLOG_URL, :status => 302)
  get "/404/:name" => "errors#page_not_found", :constraints => { :name => /.+/ }, :as => 'affiliate_page_not_found'
  get "/404" => "errors#page_not_found", :as => 'page_not_found'
  get "*path" => "errors#page_not_found"
  root :to => "home#index"
end
