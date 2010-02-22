# -*- coding: utf-8 -*-
ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.resources :password_resets
  map.resources :affiliates, :member => { :push_content_for => :post } do |affiliate|
    affiliate.resource :boosted_sites_upload, :only => [:create, :new]
  end
  map.search '/search', :controller => "searches"
  map.advanced_search '/search/advanced', :controller => 'searches', :action => 'advanced', :method => :get
  map.image_search "/search/images", :controller => "image_searches", :action => "index"
  map.resources :image_searches
  map.namespace(:admin) do |admin|
    admin.resources :affiliates, :active_scaffold => true
    admin.resources :users, :active_scaffold => true
    admin.resources :block_words, :active_scaffold => true
    admin.resources :boosted_sites, :active_scaffold => true
    admin.resources :spotlights, :active_scaffold => true
    admin.resources :affiliate_broadcasts, :only => [:new, :create]
    admin.resources :faqs, :active_scaffold => true
    admin.resources :gov_forms, :active_scaffold => true
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
  map.home_page '/', :controller => "home"
  map.auto_complete ':controller/:action',
                    :requirements => { :action => /auto_complete_for_\S+/ },
                    :conditions => { :method => :get }

  # handle static content
  map.connect '*path', :controller => 'docs', :action => 'show'
end
