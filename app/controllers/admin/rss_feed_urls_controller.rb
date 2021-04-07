class Admin::RssFeedUrlsController < Admin::AdminController
  active_scaffold :rss_feed_url do |config|
    config.label = 'Rss Feed Urls'
    config.list.sorting = { 'rss_feed_urls.url' => 'asc' }
    config.actions = %i(list show search export)
    config.columns = [:id, :url, :language, :last_crawl_status, :last_crawled_at, :rss_feeds]
    config.columns[:rss_feeds].associated_limit = 0
    config.show.columns = [:id, :language, :last_crawl_status, :last_crawled_at, :created_at, :updated_at]
    config.export.columns.exclude(:rss_feeds)
    config.action_links.add('news_items', label: 'news items',
                                          type: :member, page: true)
    config.action_links.add('destroy_news_items', label: 'Delete news items with 404',
                                                  type: :member, position: :after)
    config.action_links.add(
      'destroy_news_items',
      label: 'Delete all news items',
      type: :member,
      position: :after,
      parameters: { all: 'true' },
      confirm: 'Are you sure you want to delete all news items?'
    )
  end

  def conditions_for_collection
    { rss_feed_owner_type: Affiliate.name }
  end

  def destroy_news_items
    rss_feed_url = RssFeedUrl.find(params[:id])
    if params[:all] == 'true'
      rss_feed_url.enqueue_destroy_news_items(:high)
      render(
        plain: "You have submitted a request to delete #{rss_feed_url.url} news items."
      )
    else
      rss_feed_url.enqueue_destroy_news_items_with_404(:high)
      render(plain: "You have submitted a request to delete #{rss_feed_url.url} news items with status code 404.")
    end
  end

  def news_items
    redirect_to(admin_news_items_path(rss_feed_url_id: params[:id]))
  end
end
