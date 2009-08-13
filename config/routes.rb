ActionController::Routing::Routes.draw do |map|
  map.search '/search', :controller => "searches"
  map.root :controller => "home"
  map.home_page '/', :controller => "home"
end
