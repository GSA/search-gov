class YoutubeData < RssFeedData
  RSS_FEED_OWNER_TYPE = 'YoutubeProfile'.freeze

  def initialize(youtube_profile)
    @youtube_profile = youtube_profile
    @rss_feed = @youtube_profile.rss_feed
    @rss_feed_url_ids = []
  end

  def self.refresh_feeds
    YoutubeProfile.active.map(&:id).each do |profile_id|
      begin
        profile = YoutubeProfile.find_by_id profile_id
        next unless profile
        profile.rss_feed.touch
        YoutubeData.new(profile).import
      rescue => e
        Rails.logger.error "YoutubeData.refresh_feeds: Failed to import #{profile.username}. Message: #{e}"
      end
    end
  end

  def import
    import_uploaded_videos(@youtube_profile.username)
    import_playlist_videos(@youtube_profile.username)
    @rss_feed.rss_feed_url_ids = @rss_feed_url_ids
  end

  private

  def import_uploaded_videos(username)
    rss_feed_url = RssFeedUrl.rss_feed_owned_by_youtube_profile.
        where(url: YoutubeProfile.youtube_url(username)).first_or_initialize
    rss_feed_url.save(validate: false)
    return unless rss_feed_url
    @rss_feed_url_ids << rss_feed_url.id

    parser = YoutubeUploadedVideosParser.new(username)
    process_parsed_rss_items(rss_feed_url, parser)
  end

  def import_playlist_videos(username)
    get_playlist_ids(username).each do |playlist_id|
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_youtube_profile.
          where(url: YoutubeProfile.playlist_url(playlist_id)).first_or_initialize
      rss_feed_url.save(validate: false)
      rss_feed_url.rss_feeds << @rss_feed unless rss_feed_url.rss_feeds.exists?(@rss_feed)
      @rss_feed_url_ids << rss_feed_url.id

      parser = YoutubePlaylistVideosParser.new(playlist_id)
      process_parsed_rss_items(rss_feed_url, parser)
    end
  end

  def process_parsed_rss_items(rss_feed_url, parser)
    news_item_ids = []
    parser.each_item do |item|
      news_item = create_or_update(rss_feed_url, item)
      news_item_ids << news_item.id if news_item
    end
    NewsItem.transaction do
      news_item_ids_for_removal = rss_feed_url.news_item_ids - news_item_ids
      NewsItem.fast_delete news_item_ids_for_removal
      rss_feed_url.news_item_ids = news_item_ids
      rss_feed_url.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS,
                                      last_crawled_at: Time.now.utc)
    end
  rescue => e
    Rails.logger.error "YoutubeData#process_parsed_rss_items: #{e.message} \n #{e.backtrace.join(%Q{\n})}"
    rss_feed_url.update_attributes!(last_crawl_status: e.message,
                                    last_crawled_at: Time.now.utc)
  end

  def get_playlist_ids(username)
    parser = YoutubePlaylistsParser.new(username)
    parser.playlist_ids.sort
  end

  def create_or_update(rss_feed_url, item)
    news_item = NewsItem.where(rss_feed_url_id: [@rss_feed_url_ids],
                               link: item[:link]).first

    return if news_item && news_item.rss_feed_url_id != rss_feed_url.id
    news_item ||= rss_feed_url.news_items.build(link: item[:link])
    news_item.rss_feed_url == rss_feed_url
    news_item.assign_attributes item
    news_item.save!
    news_item
    rescue => e
      Rails.logger.warn "YoutubeData#create_or_update: #{item.inspect}, error: #{e}"
      nil
  end
end
