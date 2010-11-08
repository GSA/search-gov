class Admin::SuperfreshUrlsController < Admin::AdminController
  active_scaffold :superfresh_url do |config|
    config.list.sorting = { :crawled_at => :asc, :created_at => :asc }
    config.list.per_page = 100
    config.columns = [:url, :affiliate, :crawled_at, :created_at]
    config.create.columns = [:url]
  end
end
