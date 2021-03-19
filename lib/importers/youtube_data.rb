# frozen_string_literal: true

class YoutubeData
  DEFAULT_MAXIMUM_PROFILE_UPDATES_PER_DAY = 300

  attr_reader :all_news_item_ids,
              :profile,
              :rss_feed_url

  def self.refresh
    loop do
      profile = next_profile_to_update
      if profile
        YoutubeData.new(profile).import
        Rails.logger.info "Imported YouTube channel #{profile.channel_id}"
      else
        Rails.logger.info 'Sleeping for 5 minutes before attempting more YouTube imports'
        sleep(5.minutes)
      end
    end
  end

  def self.next_profile_to_update
    return nil if already_imported_enough_profiles_today?

    profile = YoutubeProfile.active.stale.first
    Rails.logger.info 'No stale YouTube profiles' unless profile
    profile
  end

  def self.number_of_profiles_updated_today
    YoutubeProfile.updated_today.count
  end

  def self.maximum_profile_updates_per_day
    Rails.configuration.youtube['maximum_profile_updates_per_day'] ||
      DEFAULT_MAXIMUM_PROFILE_UPDATES_PER_DAY
  end

  def self.already_imported_enough_profiles_today?
    self.number_of_profiles_updated_today >= self.maximum_profile_updates_per_day
  end

  def initialize(youtube_profile)
    @profile = youtube_profile
    @rss_feed_url = RssFeedUrl.rss_feed_owned_by_youtube_profile.
      where(url: profile.url).
      first_or_create!
    @profile.rss_feed.rss_feed_urls = [rss_feed_url]
    @all_news_item_ids = []
  end

  def import
    profile.touch :imported_at

    import_playlists
    import_playlists_items
    populate_durations

    rss_feed_url.update!(last_crawl_status: RssFeedUrl::OK_STATUS,
                         last_crawled_at: Time.now.utc)
  rescue => e
    Rails.logger.warn "#{e.message}: #{e.backtrace[0..10].compact.inspect}"
    rss_feed_url.update!(last_crawl_status: e.message,
                         last_crawled_at: Time.now.utc)
  end

  def import_playlists
    playlist_ids = YoutubeAdapter.get_playlist_ids profile.channel_id

    playlists = playlist_ids.map do |playlist_id|
      profile.youtube_playlists.
        where(playlist_id: playlist_id).
        first_or_create!
    end

    profile.youtube_playlists = playlists
  end

  def import_playlists_items
    @all_news_item_ids = []
    profile.youtube_playlists.each do |playlist|
      @all_news_item_ids |= import_playlist_items playlist
    end

    news_item_ids_for_removal = rss_feed_url.news_item_ids - all_news_item_ids
    NewsItem.fast_delete news_item_ids_for_removal
  end

  def import_playlist_items(playlist)
    playlist_news_item_ids = []
    result = YoutubeAdapter.each_playlist_item(playlist) do |playlist_item|
      news_item = process_playlist_item(playlist_news_item_ids, playlist_item)
      playlist_news_item_ids << news_item.id if news_item
    end

    if result.status_code != 304
      playlist_news_item_ids.uniq!
      playlist.news_item_ids = playlist_news_item_ids.sort
      playlist.etag = result.etag
      playlist.save!
    end

    playlist.news_item_ids
  end

  def populate_durations
    video_ids = rss_feed_url.news_items.collect do |news_item|
      news_item.guid if news_item.duration.blank?
    end.compact

    loop do
      batch = video_ids.shift(50)
      break if batch.blank?

      YoutubeAdapter.each_video(batch) { |item| assign_video_duration item }
    end
  end

  private

  def process_playlist_item(playlist_news_item_ids, playlist_item)
    video_id = playlist_item.snippet.resource_id.video_id
    link = youtube_video_url video_id
    news_item = rss_feed_url.news_items.where(link: link).
      first_or_initialize(guid: video_id)

    return news_item if !news_item.new_record? &&
                        (all_news_item_ids.include?(news_item.id) ||
                        playlist_news_item_ids.include?(news_item.id))

    create_or_update news_item, playlist_item
  end

  def create_or_update(news_item, playlist_item)
    attributes = {
      description: playlist_item.snippet.description,
      published_at: playlist_item.snippet.published_at,
      title: playlist_item.snippet.title
    }
    news_item.assign_attributes attributes

    if news_item.save
      news_item
    else
      Rails.logger.warn "YoutubeData#create_or_update: #{playlist_item.inspect}"
      nil
    end
  end

  def assign_video_duration(item)
    video_id = item.id
    duration_str = item&.content_details&.duration

    return if video_id.blank? || duration_str.blank?

    duration_in_seconds = ISO8601::Duration.new(duration_str).to_seconds.to_i
    duration = Duration.seconds_to_hoursminssecs duration_in_seconds

    link = youtube_video_url video_id
    news_item = rss_feed_url.news_items.find_by(link: link)
    news_item.duration = duration
    news_item.save!
  end

  def youtube_video_url(video_id)
    "https://www.youtube.com/watch?v=#{video_id}"
  end
end
