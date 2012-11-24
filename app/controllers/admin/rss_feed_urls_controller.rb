class Admin::RssFeedUrlsController < Admin::AdminController
  active_scaffold :rss_feed_url do |config|
    config.list.sorting = { :created_at => :asc }
  end
end
