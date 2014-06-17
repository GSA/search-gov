class ApiNewsSearch < NewsSearch
  protected

  def assign_rss_feed
    @rss_feed = @affiliate.rss_feeds.non_managed.find_by_id @channel
  end

  def navigable_feeds
    @affiliate.rss_feeds.non_managed.navigable_only.includes(:rss_feed_urls)
  end
end
