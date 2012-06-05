module RssFeedUrlsHelper
  def render_rss_feed_url_last_crawl_status(rss_feed_url)
    return rss_feed_url.last_crawl_status if RssFeedUrl::STATUSES.include?(rss_feed_url.last_crawl_status)

    dialog_id = "rss_feed_url_error_#{rss_feed_url.id}"
    render_last_crawl_status_dialog(dialog_id, rss_feed_url.url, rss_feed_url.last_crawl_status).html_safe
  end
end