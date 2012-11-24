class Admin::RssFeedsController < Admin::AdminController
  active_scaffold :rss_feed do |config|
    config.list.sorting = { :created_at => :asc }
  end
end
