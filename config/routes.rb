ActionController::Routing::Routes.draw do |map|
  map.root :controller => "home"
  map.home_page '/', :controller => "home"
end
