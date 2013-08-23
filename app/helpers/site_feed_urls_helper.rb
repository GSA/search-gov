module SiteFeedUrlsHelper
  def site_feed_url_last_crawled(last_crawled_at)
    last_crawled_at ? render_date(last_crawled_at) : 'Pending'
  end
end
