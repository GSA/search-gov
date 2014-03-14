class Admin::RssFeedsController < Admin::AdminController
  active_scaffold :rss_feed do |config|
    config.label = 'Rss Feeds'
    config.columns = [:id, :name, :owner, :rss_feed_urls, :created_at, :updated_at]
    config.actions = [:list, :search, :nested]
  end

  def conditions_for_collection
    { owner_type: Affiliate.name }
  end
end
