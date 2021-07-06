class VideoNewsSearch < NewsSearch
  self.default_per_page = 20

  protected

  def assign_rss_feed
    @rss_feed = @affiliate.rss_feeds.managed.find_by_id @channel
  end

  def navigable_feeds
    @affiliate.rss_feeds.managed.navigable_only
  end
end
