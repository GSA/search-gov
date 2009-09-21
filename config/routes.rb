ActionController::Routing::Routes.draw do |map|
  map.search '/search', :controller => "searches"
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
  end
  map.root :controller => "home"
  map.analytics_home_page '/analytics', :controller => "analytics/home"
  map.analytics_faq '/analytics/faq', :controller => "analytics/faq"
  map.query_timeline '/analytics/timeline/:query', :controller => 'analytics/timeline', :action => 'show', :requirements => { :query => /.*/ }
  map.home_page '/', :controller => "home"
end
