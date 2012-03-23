class VideoNewsSearch < NewsSearch
  def initialize(options = {})
    super(options)
  end

  def search
    rss_feeds = @rss_feed ? [@rss_feed] : @affiliate.rss_feeds.videos.navigable_only
    @rss_feed = rss_feeds.first if @rss_feed.nil? and rss_feeds and rss_feeds.count == 1
    NewsItem.search_for(@query, rss_feeds, @since, @page)
  end

  protected
  def assign_rss_feed(options)
    @rss_feed = @affiliate.rss_feeds.videos.find_by_id(options[:channel].to_i) if options[:channel].present?
  end
end
