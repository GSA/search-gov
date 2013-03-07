class YoutubeProfile < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :username, :affiliate_id
  validates_uniqueness_of :username, :scope => :affiliate_id, :message => 'has already been added', :case_sensitive => false
  validate :must_have_valid_username, :if => :username?

  before_validation :normalize_username, if: :username?
  after_create :create_video_rss_feed
  after_create :enqueue_rss_feed_fetcher
  after_destroy :hide_rss_feed

  def self.youtube_url(username)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:author] = username
    url_params[:orderby] = 'published'
    "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}".downcase
  end

  def self.xml_profile_url(username)
    "http://gdata.youtube.com/feeds/api/users/#{username}"
  end

  def self.playlist_url(playlist_id)
    "http://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?alt=rss"
  end

  def url
    YoutubeProfile.youtube_url(self.username)
  end

  def recent
    affiliate.rss_feeds.managed.videos.first.news_items.recent
  end

  def link_to_profile
    "http://youtube.com/#{username}"
  end

  private

  def normalize_username
    self.username = username.downcase.strip
  end

  def create_video_rss_feed
    @rss_feed = affiliate.rss_feeds.videos.where(is_managed: true).first_or_initialize(name: 'Videos')
    @rss_feed.shown_in_govbox = true
    @rss_feed.rss_feed_urls.build(url: url)
    @rss_feed.save!
  end

  def must_have_valid_username
    begin
      doc = Nokogiri::XML(HttpConnection.get(YoutubeProfile.xml_profile_url(username)))
      errors.add(:username, 'is invalid') if doc.xpath('//xmlns:entry').empty?
    rescue
      errors.add(:username, 'is invalid')
    end
  end

  def enqueue_rss_feed_fetcher
    Resque.enqueue_with_priority(:high, RssFeedFetcher, rss_feed.id, id)
  end

  def rss_feed
    @rss_feed.present? ? @rss_feed : affiliate.rss_feeds.videos.managed.first
  end

  def hide_rss_feed
    if affiliate.youtube_profiles(true).empty? && rss_feed
      rss_feed.update_attributes!(shown_in_govbox: false)
      rss_feed.navigation.update_attributes(is_active: false)
    end
  end
end
