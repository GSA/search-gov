class Admin::SuperfreshUrlsController < Admin::AdminController
  active_scaffold :superfresh_url do |config|
    config.list.sorting = { :created_at => :asc }
    config.list.columns = [:url, :created_at]
    config.columns[:affiliate].form_ui = :select        
    config.create.columns = [:url]
  end
end
