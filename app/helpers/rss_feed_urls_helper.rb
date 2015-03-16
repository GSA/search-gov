module RssFeedUrlsHelper
  def rss_feed_urls_for(rss_feed)
    if rss_feed.is_managed?
      rss_feed.owner.youtube_profiles.map(&:rss_feed).map(&:rss_feed_urls).flatten.select do |rss_feed_url|
        rss_feed_url.url.start_with?('https://www.youtube.com/')
      end.flatten
    else
      rss_feed.rss_feed_urls
    end
  end

  def rss_feed_url_class_hash(url)
    RssFeedUrl::STATUSES.include?(url.last_crawl_status) ? {} : { class: 'error' }
  end

  def rss_feed_url_last_crawl_status_error(url)
    return if RssFeedUrl::STATUSES.include?(url.last_crawl_status)
    content_tag :div, id: "rss-feed-url-error-#{url.id}", class: 'collapse last-crawl-status' do
      url.last_crawl_status
    end
  end

  def rss_feed_url_last_crawled_on(url)
    url.last_crawled_at.nil? ? 'Pending' : render_date(url.last_crawled_at)
  end

  def rss_feed_url_last_crawl_status(url)
    return url.last_crawl_status if RssFeedUrl::STATUSES.include?(url.last_crawl_status)
    link_to 'Error',
            "#rss-feed-url-error-#{url.id}",
            data: { toggle: 'collapse' }
  end

  def link_to_add_new_rss_feed_url(title, site, rss_feed)
    instrumented_link_to title, new_url_site_rss_feeds_path(site), rss_feed.rss_feed_urls.length, 'url'
  end
end
