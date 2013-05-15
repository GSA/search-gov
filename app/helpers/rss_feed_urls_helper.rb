module RssFeedUrlsHelper
  def rss_feed_urls_for(rss_feed)
    if rss_feed.is_managed?
      rss_feed.owner.youtube_profiles.map(&:rss_feed).map(&:rss_feed_urls).flatten.select do |rss_feed_url|
        rss_feed_url.url.start_with?('http://gdata.youtube.com/feeds/api/videos')
      end.flatten
    else
      rss_feed.rss_feed_urls
    end
  end

  def render_rss_feed_url_last_crawl_status(rss_feed_url)
    return rss_feed_url.last_crawl_status if RssFeedUrl::STATUSES.include?(rss_feed_url.last_crawl_status)

    dialog_id = "rss_feed_url_error_#{rss_feed_url.id}"
    render_last_crawl_status_dialog(dialog_id, rss_feed_url.url, rss_feed_url.last_crawl_status).html_safe
  end
end
