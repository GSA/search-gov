ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users
  map.resources :developers
  map.resource :user_session
  map.resources :password_resets
  map.resources :affiliates, :controller => 'affiliates/home', :member => { :push_content_for => :post, :embed_code => :get }, :collection => { :home => :get, :how_it_works => :get, :demo => :get } do |affiliate|
    affiliate.resources :users, :controller => 'affiliates/users', :only => [:index, :new, :create, :destroy]
    affiliate.resource :boosted_sites_upload, :controller => 'affiliates/boosted_sites_uploads', :only => [:create, :new]
    affiliate.resources :superfresh_urls, :controller => 'affiliates/superfresh', :only => [:index, :create, :destroy], :collection => { :upload => :post }
    affiliate.resources :type_ahead_search, :controller => 'affiliates/sayt', :only => [:index, :create, :destroy], :collection => { :upload => :post, :preferences => :post }
    affiliate.resources :analytics, :controller => 'affiliates/analytics', :only => [:index], :collection => {:monthly_reports => :get, :query_search => :get}
    affiliate.resources :related_topics, :controller => 'affiliates/related_topics', :only => [:index], :collection => {:preferences => :post}
  end
  map.search '/search', :controller => "searches"
  map.advanced_search '/search/advanced', :controller => 'searches', :action => 'advanced', :method => :get
  map.image_search "/search/images", :controller => "image_searches", :action => "index"
  map.recalls_search "/search/recalls", :controller => "recalls", :action => "index"
  map.resources :forms, :only => :index
  map.forms_search "/search/forms", :controller => "searches", :action => 'forms'
  map.resources :image_searches
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
    admin.resources :affiliate_templates, :active_scaffold => true
    admin.resources :users, :active_scaffold => true
    admin.resources :popular_image_queries, :active_scaffold => true
    admin.resources :sayt_filters, :active_scaffold => true
    admin.resources :sayt_suggestions, :active_scaffold => true
    admin.resources :misspellings, :active_scaffold => true
    admin.resource :sayt_suggestions_upload, :only => [:create, :new]
    admin.resources :boosted_sites, :active_scaffold => true
    admin.resources :affiliate_boosted_sites, :active_scaffold => true
    admin.resources :spotlights, :active_scaffold => true
    admin.resources :spotlight_keywords, :active_scaffold => true
    admin.resources :affiliate_broadcasts, :only => [:new, :create]
    admin.resources :faqs, :active_scaffold => true
    admin.resources :gov_forms, :active_scaffold => true
    admin.resources :clicks, :active_scaffold => true
    admin.resources :calais_related_searches, :active_scaffold => true
    admin.resources :top_searches, :only => [:index, :create]
    admin.resources :top_forms, :only => [:index, :create, :update, :destroy]
    admin.resources :superfresh_urls, :active_scaffold => true
    admin.resources :site_pages, :active_scaffold => true
  end
  map.affiliate_analytics_redirect '/admin/affiliates/:id/analytics', :controller => 'admin/affiliates', :action => 'analytics'
  map.admin_home_page '/admin', :controller => "admin/home"
  map.namespace(:analytics) do |analytics|
    analytics.resources :query_groups, :active_scaffold => true, :collection => { :bulk_add => :post }, :member => { :bulk_edit => [:get, :post]}
    analytics.resources :grouped_queries, :active_scaffold => true
  end
  map.root :controller => "home"
  map.analytics_home_page '/analytics', :controller => "analytics/home"
  map.analytics_query_search '/analytics/query_search', :controller => "analytics/query_searches"
  map.query_timeline '/analytics/timeline/:query', :controller => 'analytics/timeline', :action => 'show', :requirements => { :query => /.*/ }
  map.monthly_reports '/analytics/monthly_reports', :controller => 'analytics/monthly_reports'
  map.home_page '/', :controller => "home"
  map.contact_form '/contact_form', :controller => "home", :action => "contact_form"
  map.auto_complete ':controller/:action',
                    :requirements => { :action => /auto_complete_for_\S+/ },
                    :conditions => { :method => :get }
  map.top_searches_widget '/widgets/top_searches', :controller => "widgets", :action => "top_searches"
  map.resources :pages,
                :controller => 'pages',
                :only       => [:show]
  map.main_superfresh_feed '/superfresh', :controller => "superfresh", :action => "index"
  map.superfresh_feed '/superfresh/:feed_id', :controller => "superfresh", :action => "index"
  map.api_docs '/api', :controller => "pages", :action => "show", :id => "api"
  map.recalls_api_docs '/api/recalls', :controller => "pages", :action => "show", :id => "recalls"
  map.recalls_tos_docs '/api/tos', :controller => "pages", :action => "show", :id => "tos"
  map.usa '/usa/:url_slug', :controller => 'usa', :action => 'show', :requirements => { :url_slug => /.*/ }
  map.program '/program', :controller => "pages", :action => "show", :id => "program"
  map.searchusagov '/searchusagov', :controller => "pages", :action => "show", :id => "search"
  map.contactus '/contactus', :controller => "pages", :action => "show", :id => "contactus"
end
