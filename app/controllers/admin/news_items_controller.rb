class Admin::NewsItemsController < Admin::AdminController
  active_scaffold :news_item do |config|
    config.list.sorting = { :created_at => :asc }
  end
end
