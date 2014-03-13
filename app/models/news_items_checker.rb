class NewsItemsChecker
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(rss_feed_url_id, first_news_item_id, last_news_item_id)
    links = NewsItem.where('rss_feed_url_id = ? AND id between ? AND ?',
                           rss_feed_url_id, first_news_item_id, last_news_item_id).pluck(:link)

    news_item_ids = []
    UrlStatusCodeFetcher.fetch links do |link, status_code|
      if status_code =~ /404/
        news_item_id = NewsItem.find_by_rss_feed_url_id_and_link(rss_feed_url_id, link).pluck(:id)
        news_item_ids << news_item_id if news_item_id
      end
    end
    NewsItem.fast_delete news_item_ids
  end
end
