class RssFeedFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(id_or_rss_feed_ids, youtube_profile_id = nil, ignore_older_items = true)
    rss_feed_ids = id_or_rss_feed_ids.respond_to?(:each) ? id_or_rss_feed_ids : [id_or_rss_feed_ids]
    rss_feed_ids.each do |rss_feed_id|
      RssFeedFetcher.process_rss_feed_id(rss_feed_id, youtube_profile_id, ignore_older_items)
    end
  end

  def self.process_rss_feed_id(rss_feed_id, youtube_profile_id, ignore_older_items)
    return unless (rss_feed = RssFeed.find_by_id(rss_feed_id))
    importer = begin
      if rss_feed.is_video? && youtube_profile_id.present?
        youtube_profile = YoutubeProfile.find_by_id(youtube_profile_id)
        YoutubeData.new(rss_feed, youtube_profile) if youtube_profile
      elsif rss_feed.is_video?
        YoutubeData.new(rss_feed)
      else
        RssFeedData.new(rss_feed, ignore_older_items)
      end
    end
    importer.import if importer
  end
end