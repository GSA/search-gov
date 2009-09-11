ActionController::Routing::Routes.draw do |map|
  map.search '/search', :controller => "searches"
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
  end
  map.root :controller => "home"
  map.analytics_home_page '/analytics', :controller => "analytics/home"
  map.query_timeline '/analytics/timeline/:query', :controller => 'analytics/timeline', :action => 'show'#, :requirements => {:method => :get}
  map.home_page '/', :controller => "home"
end
