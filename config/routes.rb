Rails.application.routes.draw do

  concern :active_scaffold_association, ActiveScaffold::Routing::Association.new
  concern :active_scaffold, ActiveScaffold::Routing::Basic.new(association: true)
  get '/search' => 'searches#index', as: :search
  get '/api/search' => 'api#search', as: :api_search
  get '/search/advanced' => 'searches#advanced', as: :advanced_search
  get '/search/images' => 'image_searches#index', as: :image_search
  get '/search/docs' => 'searches#docs', as: :docs_search
  get '/search/news' => 'searches#news', as: :news_search
  get '/search/news/videos' => 'searches#video_news', as: :video_news_search
  get '/auth/logindotgov/callback', to: 'omniauth_callbacks#login_dot_gov'

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
  get '/login' => 'user_sessions#security_notification', as: :login
  get '/signup' => 'user_sessions#security_notification', as: :signup
  get '/status/outbound_rate_limit' => 'statuses#outbound_rate_limit', defaults: { format: :text }
  get '/dcv/:affiliate.txt' => 'statuses#domain_control_validation',
    defaults: { format: :text },
    constraints: { affiliate: /.*/, format: :text }

  root to: 'user_sessions#security_notification'

  resource :account, controller: "users"

  resources :users do
    post 'update_account' => 'users#update_account'
  end

  resource :user_session
  resource :human_session, only: [:new, :create]

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
      resource :click_tracking_api_instructions, only: [:show]
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
    resources :affiliates, concerns: :active_scaffold
    resources :affiliate_notes, concerns: :active_scaffold
    resources :affiliate_templates, concerns: :active_scaffold
    resources :users, concerns: :active_scaffold
    resources :sayt_filters, concerns: :active_scaffold
    resources :sayt_suggestions, concerns: :active_scaffold
    resources :misspellings, concerns: :active_scaffold
    resources :affiliate_boosted_contents, concerns: :active_scaffold
    resources :document_collections, concerns: :active_scaffold
    resources :url_prefixes, concerns: :active_scaffold
    resources :catalog_prefixes, concerns: :active_scaffold
    resources :site_feed_urls, concerns: :active_scaffold
    resources :superfresh_urls, concerns: :active_scaffold
    resources :superfresh_urls_bulk_upload, only: :index do
      collection do
        post :upload
      end
    end
    resources :agencies, concerns: :active_scaffold
    resources :agency_queries, concerns: :active_scaffold
    resources :agency_organization_codes, concerns: :active_scaffold
    resources :federal_register_agencies, concerns: :active_scaffold do
      collection { get 'reimport' }
    end
    resources :federal_register_documents, concerns: :active_scaffold
    resources :outbound_rate_limits, concerns: :active_scaffold
    resources :search_modules, concerns: :active_scaffold
    resources :excluded_domains, concerns: :active_scaffold
    resources :affiliate_scopes, concerns: :active_scaffold
    resources :site_domains, concerns: :active_scaffold
    resources :features, concerns: :active_scaffold
    resources :affiliate_feature_additions, concerns: :active_scaffold
    resources :help_links, concerns: :active_scaffold
    resources :compare_search_results, only: :index
    resources :bing_urls, concerns: :active_scaffold
    resources :statuses, concerns: :active_scaffold
    resources :system_alerts, concerns: :active_scaffold
    resources :tags, concerns: :active_scaffold
    resources :trending_urls, only: :index
    resources :news_items, concerns: :active_scaffold
    resources :suggestion_blocks, concerns: :active_scaffold
    resources :rss_feeds, concerns: :active_scaffold
    resources :rss_feed_urls, concerns: :active_scaffold do
      member do
        get 'destroy_news_items'
        get 'news_items'
      end
    end
    resource :search_module_ctrs, only: [:show]
    resource :site_ctrs, only: [:show]
    resource :query_ctrs, only: [:show]
    resources :whitelisted_v1_api_handles, concerns: :active_scaffold
    resources :hints, concerns: :active_scaffold do
      collection { get 'reload_hints' }
    end
    resources :i14y_drawers, concerns: :active_scaffold
    resources :languages, concerns: :active_scaffold
    resources :routed_queries, concerns: :active_scaffold
    resources :routed_query_keywords, concerns: :active_scaffold
    resources :watchers, concerns: :active_scaffold
    resources :searchgov_domains, concerns: :active_scaffold do
      resources :searchgov_urls, concerns: :active_scaffold do
        member do
          post 'fetch'
        end
      end
      resources :sitemaps, concerns: :active_scaffold do
        member do
          post 'fetch'
        end
      end
    end
  end

  match '/admin/affiliates/:id/analytics' => 'admin/affiliates#analytics', :as => :affiliate_analytics_redirect, via: :get
  match '/admin/site_domains/:id/trigger_crawl' => 'admin/site_domains#trigger_crawl', :as => :site_domain_trigger_crawl, via: :get
  match '/admin' => 'admin/home#index', :as => :admin_home_page, via: :get

  get '/superfresh' => 'superfresh#index', :as => :main_superfresh_feed
  get '/superfresh/:feed_id' => 'superfresh#index', :as => :superfresh_feed

  get '/user/developer_redirect' => 'users#developer_redirect', :as => :developer_redirect
  get '/program' => redirect(
    Rails.application.secrets.organization[:blog_url],
    status: 302
  )

  get "*path" => redirect(
    Rails.application.secrets.organization[:page_not_found_url],
    status: 302
  )

  get "/c/search" => 'dev#null', :as => :search_consumer_search
  get "/c/admin/:site_name" => 'dev#null', :as => :search_consumer_admin
  get "/c/search/rss" => 'dev#null', :as => :search_consumer_news_search
  get "/c/search/docs" => 'dev#null', :as => :search_consumer_docs_search
end
