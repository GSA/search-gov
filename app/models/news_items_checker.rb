require 'benchmark'

class NewsItemsChecker
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary
  @@logger = ActiveSupport::BufferedLogger.new(Rails.root.to_s + "/log/news_items_checker.log")

  def self.perform(rss_feed_url_ids, is_throttled = false)
    rss_feed_url_ids = [rss_feed_url_ids] unless rss_feed_url_ids.is_a?(Array)
    rss_feed_url_ids.shuffle.each do |rss_feed_url_id|
      check_rss_feed_url rss_feed_url_id, is_throttled
    end
  end

  def self.check_rss_feed_url(rss_feed_url_id, is_throttled)
    NewsItem.where('rss_feed_url_id = ?', rss_feed_url_id).find_in_batches do |group|
      news_item_ids_for_deletion = []
      elapsed_real_time = Benchmark.realtime do
        news_item_ids_for_deletion = get_news_item_ids_for_deletion rss_feed_url_id, group.map(&:link).shuffle, is_throttled
      end
      @@logger.info ({ rss_feed_url_id: rss_feed_url_id,
                       url: RssFeedUrl.find_by_id(rss_feed_url_id).url,
                       news_items_count: group.count,
                       elapsed: elapsed_real_time,
                       pid: Process.pid,
                       ts: Time.current }.to_json)
      NewsItem.fast_delete news_item_ids_for_deletion
    end
  end

  def self.get_news_item_ids_for_deletion(rss_feed_url_id, links, is_throttled)
    links_for_deletion = []
    UrlStatusCodeFetcher.fetch links, is_throttled do |link, status_code|
      links_for_deletion << link if status_code =~ /404/
    end
    NewsItem.where(rss_feed_url_id: rss_feed_url_id,
                   link: links_for_deletion).pluck(:id)
  end
end
