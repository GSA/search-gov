class Admin::SuperfreshUrlsController < Admin::AdminController
  active_scaffold :superfresh_url do |config|
    config.list.sorting = { :crawled_at => :asc, :created_at => :asc }
    config.list.columns = [:url, :crawled_at, :created_at]
    config.columns[:affiliate].form_ui = :select        
    config.create.columns = [:url]
  end
end
