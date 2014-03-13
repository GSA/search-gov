class Admin::RssFeedUrlsController < Admin::AdminController
  active_scaffold :rss_feed_url do |config|
    config.label = 'Rss Feed Urls'
    config.list.sorting = { 'rss_feed_urls.url' => 'asc' }
    config.actions = [:list, :show, :search]
    config.columns = [:id, :url, :language, :last_crawl_status, :last_crawled_at, :rss_feeds]
    config.columns[:rss_feeds].associated_limit = 0
    config.show.columns = [:id, :language, :last_crawl_status, :last_crawled_at, :created_at, :updated_at]
    config.action_links.add 'destroy_news_items', label: 'Delete news items',
                            type: :member, position: :after, parameters: { all: 'true' }
    config.action_links.add 'destroy_news_items', label: 'Delete news items with 404',
                            type: :member, position: :after
  end

  def conditions_for_collection
    { rss_feed_owner_type: Affiliate.name }
  end

  def destroy_news_items
    rss_feed_url = RssFeedUrl.find params[:id]
    if params[:all] == 'true'
      rss_feed_url.enqueue_destroy_news_items(:high)
      render text: "You have submitted a request to delete #{rss_feed_url.url} news items."
    else
      rss_feed_url.enqueue_destroy_news_items_with_404(:high)
      render text: "You have submitted a request to delete #{rss_feed_url.url} news items with status code 404."
    end
  end
end
