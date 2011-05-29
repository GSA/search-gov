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
      get :preview
      post :cancel_staged_changes_for
    end
    collection do
      get :home
      get :how_it_works
      get :demo
      put :update_contact_information
    end
    resources :users, :controller => 'affiliates/users', :only => [:index, :new, :create, :destroy]
    resources :boosted_contents, :controller => "affiliates/boosted_contents" do
      collection do
        delete :destroy_all
        post :bulk
      end
    end
    resources :superfresh_urls, :controller => 'affiliates/superfresh', :only => [:index, :create, :destroy] do
      collection do
        post :upload
      end
    end
    resources :type_ahead_search, :controller => "affiliates/sayt", :as => "type_ahead_search" do
      collection do
        post :upload
        post :preferences
      end
    end
    resources :analytics, :controller => "affiliates/analytics", :only => [:index] do
      collection do
        get :monthly_reports
        get :query_search
      end
    end
    resources :related_topics, :controller => "affiliates/related_topics" do
      collection do
        post :preferences
      end
    end
    resources :api, :controller => "affiliates/api"
  end
  match '/search' => 'searches#index', :as => :search
  get '/search/advanced' => 'searches#advanced', :as => :advanced_search
  match '/search/images' => 'image_searches#index', :as => :image_search
  match '/images' => 'images#index', :as => :images
  resources :recalls, :only => [:index]
  match '/search/recalls' => 'recalls#search', :as => :recalls_search
  resources :forms, :only => :index
  match '/search/forms' => 'searches#forms', :as => :forms_search
  resources :image_searches
  namespace :admin do
    resources :affiliates do as_routes end
    resources :affiliate_templates do as_routes end
    resources :users do as_routes end
    resources :popular_image_queries do as_routes end
    resources :sayt_filters do as_routes end
    resources :sayt_suggestions do as_routes end
    resources :misspellings do as_routes end
    resource :sayt_suggestions_upload, :only => [:create, :new]
    resources :boosted_contents do as_routes end
    resources :affiliate_boosted_contents do as_routes end
    resources :spotlights do as_routes end
    resources :spotlight_keywords do as_routes end
    resources :affiliate_broadcasts, :only => [:new, :create]
    resources :faqs do as_routes end
    resources :gov_forms do as_routes end
    resources :clicks do as_routes end
    resources :calais_related_searches do as_routes end
    resources :top_searches, :only => [:index, :create, :new]
    resources :top_forms, :only => [:index, :create, :update, :destroy]
    resources :superfresh_urls do as_routes end
    resources :site_pages do as_routes end
    resources :agencies do as_routes end
    resources :agency_queries do as_routes end
    resources :logfile_blocked_queries do as_routes end
    resources :logfile_blocked_ips do as_routes end
    resources :logfile_blocked_class_cs do as_routes end
    resources :logfile_whitelisted_class_cs do as_routes end
    resources :logfile_blocked_regexps do as_routes end
  end

  match '/admin/affiliates/:id/analytics' => 'admin/affiliates#analytics', :as => :affiliate_analytics_redirect
  match '/admin' => 'admin/home#index', :as => :admin_home_page
  namespace :analytics do
    resources :query_groups do
      as_routes
      collection do
        post :bulk_add
      end
      member do
        get :bulk_edit
        post :bulk_edit
      end
    end
    resources :grouped_queries
  end

  match '/' => 'home#index'
  match '/analytics' => 'analytics/home#index', :as => :analytics_home_page
  match '/analytics/queries' => 'analytics/home#queries', :as => :analytics_queries
  match '/analytics/query_search' => 'analytics/query_searches#index', :as => :analytics_query_search
  match '/analytics/timeline/:query' => 'analytics/timeline#show', :as => :query_timeline, :constraints => { :query => /.*/ }
  match 'affiliates/:id/analytics/timeline/:query' => 'affiliates/timeline#show', :as => :affiliate_query_timeline
  match '/analytics/monthly_reports' => 'analytics/monthly_reports#index', :as => :monthly_reports
  match '/' => 'home#index', :as => :home_page
  match '/contact_form' => 'home#contact_form', :as => :contact_form
  #get ':controller/:action' => '#index', :as => :auto_complete, :constraints => { :action => /auto_complete_for_\S+/ }
  get '/searches/auto_complete_for_search_query' => 'searches#auto_complete_for_search_query', :as => 'auto_complete_for_search_query'
  match '/widgets/top_searches' => 'widgets#top_searches', :as => :top_searches_widget
  match '/widgets/trending_searches' => 'widgets#trending_searches', :as => :trending_searches_widget
  resources :pages
  match '/superfresh' => 'superfresh#index', :as => :main_superfresh_feed
  match '/superfresh/:feed_id' => 'superfresh#index', :as => :superfresh_feed
  match '/usa/:url_slug' => 'usa#show', :as => :usa, :constraints => { :url_slug => /.*/ }
  match '/usa/' => 'home#index'
  match '/program' => 'pages#show', :as => :program, :id => 'program'
  match '/searchusagov' => 'pages#show', :as => :searchusagov, :id => 'search'
  match '/contactus' => 'pages#show', :as => :contactus, :id => 'contactus'
  match '/api/search' => 'affiliates/api#search', :as => :api_search
  match '/api' => 'pages#show', :as => :api_docs, :id => 'api'
  match '/api/recalls' => 'pages#show', :as => :recalls_api_docs, :id => 'recalls'
  match '/api/tos' => 'pages#show', :as => :recalls_tos_docs, :id => 'tos'
  match '/login' => 'user_sessions#new', :as => :login
  match "/sayt" => "sayt#index"
  match "/clicked" => "clicked#index"
  root :to => "home#index"
end
