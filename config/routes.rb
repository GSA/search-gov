ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.resources :password_resets
  map.resources :affiliates, :member => { :push_content_for => :post }
  map.search '/search', :controller => "searches"
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
    admin.resources :users, :active_scaffold => true
    admin.resources :block_words, :active_scaffold => true
    admin.resources :boosted_sites, :active_scaffold => true
    admin.resources :affiliate_broadcasts, :only => [:new, :create]
  end
  map.namespace(:analytics) do |admin|
    admin.resources :query_groups, :active_scaffold => true
    admin.resources :grouped_queries, :active_scaffold => true
  end
  map.root :controller => "home"
  map.analytics_home_page '/analytics', :controller => "analytics/home"
  map.analytics_faq '/analytics/faq', :controller => "analytics/faq"
  map.analytics_query_search '/analytics/query_search', :controller => "analytics/query_searches"
  map.query_timeline '/analytics/timeline/:query', :controller => 'analytics/timeline', :action => 'show', :requirements => { :query => /.*/ }
  map.home_page '/', :controller => "home"
  map.auto_complete ':controller/:action',
                    :requirements => { :action => /auto_complete_for_\S+/ },
                    :conditions => { :method => :get }
end
