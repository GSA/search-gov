class VideoNewsSearch < NewsSearch
  def initialize(options = {})
    super(options)
    @per_page = DEFAULT_VIDEO_PER_PAGE if options[:per_page].blank?
  end

  protected

  def assign_module_tag
    @module_tag = @total > 0 ? 'VIDS' : nil
  end

  def assign_rss_feed(channel_id)
    @rss_feed = @affiliate.rss_feeds.videos.find_by_id(channel_id.to_i) if channel_id.present?
  end

  def navigable_feeds
    @affiliate.rss_feeds.videos.navigable_only
  end
end