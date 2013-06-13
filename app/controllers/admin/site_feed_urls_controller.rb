class Admin::SiteFeedUrlsController < Admin::AdminController
  active_scaffold :site_feed_url do |config|
    config.actions.exclude :create
    config.list.sorting = { :created_at => :asc }
    config.update.columns = [:quota]
  end
end
