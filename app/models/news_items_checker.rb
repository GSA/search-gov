class NewsItemsChecker
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(rss_feed_url_id)
    NewsItem.where(rss_feed_url_id: rss_feed_url_id).
        select([:id, :link]).
        find_in_batches(batch_size: 5000) do |group|
      UrlStatusCodeFetcher.fetch group.map(&:link) do |url, status_code|
        if status_code =~ /404/
          news_item = NewsItem.find_by_rss_feed_url_id_and_link(rss_feed_url_id, url)
          news_item.destroy if news_item
        end
      end
    end
  end
end
