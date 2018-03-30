Rails.application.routes.draw do

  get '/search' => 'searches#index', as: :search
  get '/api/search' => 'api#search', as: :api_search
  get '/search/advanced' => 'searches#advanced', as: :advanced_search
  get '/search/images' => 'image_searches#index', as: :image_search
  get '/search/docs' => 'searches#docs', as: :docs_search
  get '/search/news' => 'searches#news', as: :news_search
  get '/search/news/videos' => 'searches#video_news', as: :video_news_search

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get '/agencies/search' => 'agencies#search'
    end

    namespace :v2 do
      get '/search' => 'searches#blended'
      get '/search/azure' => 'searches#azure'
      get '/search/bing' => 'searches#bing'
      get '/search/azure/web' => 'searches#azure_web'
      get '/search/azure/image' => 'searches#azure_image'
      get '/search/gss' => 'searches#gss'
      get '/search/i14y' => 'searches#i14y'
      get '/search/video' => 'searches#video'
      get '/search/docs' => 'searches#docs'
      get '/agencies/search' => 'agencies#search'
    end
  end

  mount SearchConsumer::API => '/api/c'

  get '/sayt' => 'sayt#index'
  get '/clicked' => 'clicked#index'
  get '/healthcheck' => 'health_checks#new'
  get '/login' => 'user_sessions#new', as: :login
  get '/signup' => 'users#new', as: :signup
  get '/status/outbound_rate_limit' => 'statuses#outbound_rate_limit', defaults: { format: :text }
  get '/dcv/:affiliate.txt' => 'statuses#domain_control_validation',
    defaults: { format: :text },
    constraints: { affiliate: /.*/, format: :text }
  root to: redirect('/login')

  resource :account, :controller => "users"
  resources :users
  resource :user_session
  resource :human_session, :only => [:new, :create]
  resources :password_resets
  resources :email_verification, :only => :show
  resources :complete_registration, :only => [:edit, :update]

  scope module: 'sites' do
    resources :sites do
      member { put :pin }

      resource :alert, only: [:edit, :create, :update]

      resource :api_access_key, only: [:show]
      resource :api_instructions, only: [:show] do
        collection do
          get :commercial_keys
        end
      end
      resource :i14y_api_instructions, only: [:show]
      resource :type_ahead_api_instructions, only: [:show]
      resource :clicks, only: [:new, :create]
      resource :query_clicks, only: [:show]
      resource :query_referrers, only: [:show]
      resource :query_downloads, only: [:show]
      resource :query_drilldowns, only: [:show]
      resource :click_drilldowns, only: [:show]
      resource :click_queries, only: [:show]
      resource :referrer_queries, only: [:show]
      resource :queries, only: [:new, :create]
      resource :referrers, only: [:new, :create]

      resource :content, only: [:show]
      resource :display, only: [:edit, :update] do
        collection { get :new_connection }
      end
      resource :embed_code, only: [:show]
      resource :template, only: [:edit, :update]
      resource :font_and_colors, only: [:edit, :update]
      resource :templated_font_and_colors, only: [:edit, :update]
      resource :header_and_footer, only: [:edit, :update] do
        collection do
          get :new_footer_link
          get :new_header_link
        end
      end
      resource :image_assets, only: [:edit, :update]
      resource :no_results_pages, only: [:edit, :update] do
        collection do
          get :new_no_results_pages_alt_link
        end
      end
      resource :monthly_reports, only: [:show]
      resource :preview, only: [:show]
      resource :setting, only: [:edit, :update]
      resource :clone, only: [:new, :create]
      resource :supplemental_feed,
               controller: 'site_feed_urls',
               only: [:edit, :create, :update, :destroy]
      resource :third_party_tracking_request, only: [:new, :create]
      resource :autodiscovery, only: [:create]

      resources :best_bets_graphics, controller: 'featured_collections', except: [:show] do
        collection do
          get :new_keyword
          get :new_link
        end
      end

      resources :best_bets_texts, controller: 'boosted_contents', except: [:show] do
        collection do
          get :new_keyword
        end
      end

      resources :best_bets_texts_bulk_upload, controller: 'boosted_contents_bulk_uploads', only: [:new, :create]

      resources :collections, controller: 'document_collections' do
        collection { get :new_url_prefix }
      end
      resources :domains, controller: 'site_domains', except: [:show] do
        member { get :advanced }
      end
      resources :routed_queries do
        collection { get :new_routed_query_keyword }
      end
      resources :filter_urls,
                controller: 'excluded_urls',
                only: [:index, :new, :create, :destroy]
      resources :tag_filters, only: [:index, :new, :create, :destroy]
      resources :flickr_urls,
                controller: 'flickr_profiles',
                only: [:index, :new, :create, :destroy]
      resources :instagram_usernames,
                controller: 'instagram_profiles',
                only: [:index, :destroy]
      resources :rss_feeds do
        collection { get :new_url }
      end
      resources :supplemental_urls,
                controller: 'indexed_documents',
                except: [:show, :edit, :update]
      resources :twitter_handles,
                controller: 'twitter_profiles',
                only: [:index, :new, :create, :destroy]
      resources :users, only: [:index, :new, :create, :destroy]
      resources :youtube_channels,
                controller: 'youtube_profiles',
                only: [:index, :new, :create, :destroy]
      resources :memberships, only: [:update]
      resources :i14y_drawers
      resource :filtered_analytics_toggle, only: :create
      resources :watchers
      resources :no_results_watchers, controller: "watchers", type: "NoResultsWatcher"
      resources :low_query_ctr_watchers, controller: "watchers", type: "LowQueryCtrWatcher"
    end
  end

  get '/help_docs' => 'help_docs#show'
  get '/affiliates', to: redirect('/sites')
  get '/affiliates/:id', to: redirect('/sites/%{id}')
  get '/affiliates/:id/:some_action', to: redirect('/sites/%{id}')

  namespace :admin do
    resources :affiliates do as_routes end
    resources :affiliate_notes do as_routes end
    resources :affiliate_templates do as_routes end
    resources :users do as_routes end
    resources :sayt_filters do as_routes end
    resources :sayt_suggestions do as_routes end
    resources :misspellings do as_routes end
    resources :affiliate_boosted_contents do as_routes end
    resources :document_collections do as_routes end
    resources :url_prefixes do as_routes end
    resources :catalog_prefixes do as_routes end
    resources :site_feed_urls do as_routes end
    resources :superfresh_urls do as_routes end
    resources :superfresh_urls_bulk_upload, :only => :index do
      collection do
        post :upload
      end
    end
    resources :agencies do as_routes end
    resources :agency_queries do as_routes end
    resources :agency_organization_codes do as_routes end
    resources :federal_register_agencies do
      collection { get 'reimport' }
      as_routes
    end
    resources :federal_register_documents do as_routes end
    resources :outbound_rate_limits do as_routes end
    resources :search_modules do as_routes end
    resources :excluded_domains do as_routes end
    resources :affiliate_scopes do as_routes end
    resources :site_domains do as_routes end
    resources :features do as_routes end
    resources :affiliate_feature_additions do as_routes end
    resources :help_links do as_routes end
    resources :compare_search_results, :only => :index
    resources :bing_urls do as_routes end
    resources :statuses do as_routes end
    resources :system_alerts do as_routes end
    resources :tags do as_routes end
    resources :trending_urls, :only => :index
    resources :news_items do as_routes end
    resources :suggestion_blocks do as_routes end
    resources :rss_feeds do as_routes end
    resources :rss_feed_urls do
      member do
        get 'destroy_news_items'
        get 'news_items'
      end
      as_routes
    end
    resource :search_module_ctrs, only: [:show]
    resource :site_ctrs, only: [:show]
    resource :query_ctrs, only: [:show]
    resources :whitelisted_v1_api_handles do as_routes end
    resources :hints do
      collection { get 'reload_hints' }
      as_routes
    end
    resources :i14y_drawers do as_routes end
    resources :languages do as_routes end
    resources :routed_queries do as_routes end
    resources :routed_query_keywords do as_routes end
    resources :watchers do as_routes end
  end

  match '/admin/affiliates/:id/analytics' => 'admin/affiliates#analytics', :as => :affiliate_analytics_redirect, via: :get
  match '/admin/site_domains/:id/trigger_crawl' => 'admin/site_domains#trigger_crawl', :as => :site_domain_trigger_crawl, via: :get
  match '/admin' => 'admin/home#index', :as => :admin_home_page, via: :get

  get '/superfresh' => 'superfresh#index', :as => :main_superfresh_feed
  get '/superfresh/:feed_id' => 'superfresh#index', :as => :superfresh_feed

  get '/user/developer_redirect' => 'users#developer_redirect', :as => :developer_redirect
  get '/program' => redirect(Rails.application.secrets.organization['blog_url'], :status => 302)

  get "*path" => redirect(Rails.application.secrets.organization['page_not_found_url'], status: 302)

  get "/c/search" => 'dev#null', :as => :search_consumer_search
  get "/c/admin/:site_name" => 'dev#null', :as => :search_consumer_admin
  get "/c/search/rss" => 'dev#null', :as => :search_consumer_news_search
  get "/c/search/docs" => 'dev#null', :as => :search_consumer_docs_search
end
