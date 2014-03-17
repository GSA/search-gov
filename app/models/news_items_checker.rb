require 'benchmark'

class NewsItemsChecker
  extend Resque::Plugins::Priority
  @queue = :primary
  @@logger = ActiveSupport::BufferedLogger.new(Rails.root.to_s + "/log/news_items_checker.log")
  @@logger.auto_flushing = 1

  def self.perform(rss_feed_url_ids, first_news_item_id, last_news_item_id, is_throttled = false)
    rss_feed_url_ids = [rss_feed_url_ids] unless rss_feed_url_ids.is_a?(Array)
    rss_feed_url_ids.shuffle.each do |rss_feed_url_id|
      check_rss_feed_url rss_feed_url_id, first_news_item_id, last_news_item_id, is_throttled
    end
  end

  def self.check_rss_feed_url(rss_feed_url_id, first_news_item_id, last_news_item_id, is_throttled)
    NewsItem.where('rss_feed_url_id = ? AND id between ? AND ?',
                   rss_feed_url_id, first_news_item_id, last_news_item_id).find_in_batches do |group|

      news_item_ids_for_deletion = []
      elapsed_real_time = Benchmark.realtime do
        news_item_ids_for_deletion = get_news_item_ids_for_deletion rss_feed_url_id, group.map(&:link).shuffle, is_throttled
      end
      @@logger.info ({ rss_feed_url_id: rss_feed_url_id,
                       url_count: group.count,
                       elapsed: elapsed_real_time,
                       pid: Process.pid }.to_json)
      NewsItem.fast_delete news_item_ids_for_deletion
    end
  end

  def self.get_news_item_ids_for_deletion(rss_feed_url_id, links, is_throttled)
    news_item_ids_for_deletion = []
    UrlStatusCodeFetcher.fetch links, is_throttled do |link, status_code|
      if status_code =~ /404/
        news_item_id = NewsItem.find_by_rss_feed_url_id_and_link(rss_feed_url_id, link).pluck(:id)
        news_item_ids_for_deletion << news_item_id if news_item_id
      end
    end
    news_item_ids_for_deletion
  end
end
