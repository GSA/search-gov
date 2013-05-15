class YoutubeProfile < ActiveRecord::Base
  has_one :rss_feed, as: :owner, dependent: :destroy
  has_and_belongs_to_many :affiliates

  before_validation :normalize_username, if: :username?

  validates_presence_of :username
  validates_uniqueness_of :username, message: 'has already been added', case_sensitive: false
  validate :must_have_valid_username, if: :username?

  after_create :create_video_rss_feed

  scope :active, joins(:affiliates, :rss_feed).order('rss_feeds.updated_at asc').uniq

  def self.youtube_url(username)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:author] = username
    url_params[:orderby] = 'published'
    "http://gdata.youtube.com/feeds/api/videos?#{url_params.to_param}".downcase
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
    rss_feed.news_items.recent
  end

  def link_to_profile
    "http://youtube.com/#{username}"
  end

  private

  def normalize_username
    self.username = username.downcase.strip
  end

  def create_video_rss_feed
    unless rss_feed
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_youtube_profile.where(url: url).first_or_create!
      create_rss_feed!(name: username, rss_feed_urls: [rss_feed_url])
    end
  end

  def must_have_valid_username
    begin
      doc = Nokogiri::XML(HttpConnection.get(YoutubeProfile.xml_profile_url(username)))
      errors.add(:username, 'is invalid') if doc.xpath('//xmlns:entry').empty?
    rescue
      errors.add(:username, 'is invalid')
    end
  end
end
