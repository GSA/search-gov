ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.resources :password_resets
  map.resources :affiliates, :member => { :push_content_for => :post, :embed_code => :get } do |affiliate|
    affiliate.resource :boosted_sites_upload, :only => [:create, :new]
  end
  map.click '/click', :controller => "clicks", :action => "create"
  map.affiliate_analytics_home_page '/affiliates/:id/analytics', :controller => 'affiliates', :action => 'analytics'
  map.affiliate_analytics_query_search '/affiliates/:id/query_search', :controller => 'affiliates', :action => 'query_search'
  map.affiliate_analytics_monthly_reports '/affiliates/:id/monthly_reports', :controller => 'affiliates', :action => 'monthly_reports'
  map.search '/search', :controller => "searches"
  map.advanced_search '/search/advanced', :controller => 'searches', :action => 'advanced', :method => :get
  map.image_search "/search/images", :controller => "image_searches", :action => "index"
  map.recall_search "/search/recalls", :controller => "recalls", :action => "index"
  map.resources :image_searches
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
    admin.resources :affiliate_templates, :active_scaffold => true
    admin.resources :users, :active_scaffold => true
    admin.resources :block_words, :active_scaffold => true
    admin.resources :sayt_filters, :active_scaffold => true
    admin.resources :sayt_suggestions, :active_scaffold => true
    admin.resources :accepted_sayt_suggestions, :active_scaffold => true
    admin.resource :sayt_suggestions_upload, :only => [:create, :new]
    admin.resources :boosted_sites, :active_scaffold => true
    admin.resources :spotlights, :active_scaffold => true
    admin.resources :affiliate_broadcasts, :only => [:new, :create]
    admin.resources :faqs, :active_scaffold => true
    admin.resources :gov_forms, :active_scaffold => true
    admin.resources :clicks, :active_scaffold => true
  end
  map.admin_home_page '/admin', :controller => "admin/home"
  map.namespace(:analytics) do |admin|
    admin.resources :query_groups, :active_scaffold => true
    admin.resources :grouped_queries, :active_scaffold => true
  end
  map.root :controller => "home"
  map.analytics_home_page '/analytics', :controller => "analytics/home"
  map.analytics_faq '/analytics/faq', :controller => "analytics/faq"
  map.analytics_query_search '/analytics/query_search', :controller => "analytics/query_searches"
  map.query_timeline '/analytics/timeline/:query', :controller => 'analytics/timeline', :action => 'show', :requirements => { :query => /.*/ }
  map.monthly_reports '/analytics/monthly_reports', :controller => 'analytics/monthly_reports'
  map.top_queries 'analytics/top_queries', :controller => 'analytics/monthly_reports', :action => 'top_queries'
  map.daily_top_queries 'analytics/daily_top_queries', :controller => 'analytics/home', :action => 'daily_top_queries'
  map.home_page '/', :controller => "home"
  map.contact_form '/contact_form', :controller => "home", :action => "contact_form"
  map.auto_complete ':controller/:action',
                    :requirements => { :action => /auto_complete_for_\S+/ },
                    :conditions => { :method => :get }
  map.resources :pages,
                :controller => 'pages',
                :only       => [:show]
end
