ActionController::Routing::Routes.draw do |map|
  map.search '/search', :controller => "searches"
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
  end
  map.root :controller => "home"
  map.home_page '/', :controller => "home"
end
