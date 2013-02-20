class YoutubeData < RssFeedData
  def initialize(rss_feed, youtube_profile = nil)
    @rss_feed = rss_feed
    @youtube_profile = youtube_profile
    @affiliate = @rss_feed.affiliate
    @rss_feed_url_ids = []
    @news_item_ids = []
  end

  def import
    if @youtube_profile.present?
      import_uploaded_videos(@youtube_profile.username)
    else
      usernames = @affiliate.youtube_profiles(true).collect(&:username)
      usernames.each { |username| import_uploaded_videos(username) }
      usernames.each { |username| import_playlist_videos(username) }
      if usernames_have_not_changed?(usernames)
        @rss_feed.rss_feed_url_ids = @rss_feed_url_ids
        @rss_feed.news_item_ids = @news_item_ids
        @rss_feed.destroy if usernames.empty?
      end
    end
  end

  private

  def import_uploaded_videos(username)
    rss_feed_url = @rss_feed.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url(username))
    return unless rss_feed_url
    @rss_feed_url_ids << rss_feed_url.id

    parser = YoutubeUploadedVideosParser.new(username)
    process_parsed_rss_items(rss_feed_url, parser)
  end

  def import_playlist_videos(username)
    playlist_ids = get_playlist_ids(username)

    playlist_ids.each do |playlist_id|
      rss_feed_url = @rss_feed.rss_feed_urls.
          where(url: YoutubeProfile.playlist_url(playlist_id)).
          first_or_create!
      @rss_feed_url_ids << rss_feed_url.id

      parser = YoutubePlaylistVideosParser.new(playlist_id)
      process_parsed_rss_items(rss_feed_url, parser)
    end
  end

  def process_parsed_rss_items(rss_feed_url, parser)
    begin
      parser.each_item do |item|
        news_item = find_and_initialize(rss_feed_url, item)
        @news_item_ids << news_item.id
      end
      rss_feed_url.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS,
                                      last_crawled_at: Time.now.utc)
    rescue => e
      rss_feed_url.update_attributes!(last_crawl_status: e.message,
                                      last_crawled_at: Time.now.utc)
    end
  end

  def get_playlist_ids(username)
    parser = YoutubePlaylistsParser.new(username)
    parser.playlist_ids.sort
  end

  def find_and_initialize(rss_feed_url, item)
    news_item = @rss_feed.news_items.where(link: item[:link]).first_or_initialize
    if news_item.new_record? || !@rss_feed_url_ids.include?(news_item.rss_feed_url.id)
      news_item.rss_feed_url = rss_feed_url
    end
    news_item.link = item[:link]
    news_item.guid = item[:guid]
    news_item.title = item[:title]
    news_item.description = item[:description]
    news_item.published_at = item[:published_at]
    news_item.save!
    news_item
  end

  def usernames_have_not_changed?(usernames)
    @affiliate.youtube_profiles(true).collect(&:username).sort == usernames.sort
  end
end