class YoutubeProfile < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :username, :affiliate_id
  validates_uniqueness_of :username, :scope => :affiliate_id, :message => 'has already been added'
  validate :must_have_valid_username, :if => :username?

  before_validation :normalize_username
  after_create :create_video_rss_feed, :synchronize_managed_feed
  after_update :update_video_rss_feed
  after_destroy :synchronize_managed_feed

  class << self

    def youtube_url(username)
      url_params = ActiveSupport::OrderedHash.new
      url_params[:alt] = 'rss'
      url_params[:author] = username
      url_params[:orderby] = 'published'
      "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}".downcase
    end

    def xml_profile_url(username)
      "http://gdata.youtube.com/feeds/api/users/#{username}"
    end
  end

  def url
    YoutubeProfile.youtube_url(self.username)
  end

  def recent
    rss_feed_url = nil
    self.affiliate.rss_feeds.each do |rss_feed|
      rss_feed_url = rss_feed.rss_feed_urls.find_by_url(self.url)
      break if rss_feed_url
    end
    rss_feed_url ? rss_feed_url.news_items.recent : nil
  end

  def link_to_profile
    "http://youtube.com/#{self.username}"
  end

  private

  def normalize_username
    self.username.strip! unless self.username.nil?
  end

  def create_video_rss_feed
    unless affiliate.rss_feeds.managed.videos.collect(&:rss_feed_urls).flatten.collect(&:url).include?(url)
      rss_feed = affiliate.rss_feeds.managed.videos.first
      rss_feed ||= affiliate.rss_feeds.build(:name => 'Videos')
      rss_feed.is_managed = true
      rss_feed.rss_feed_urls.build(:url => url)
      rss_feed.save!
    end
  end

  def update_video_rss_feed
    synchronize_managed_feed if self.username_changed?
  end

  def synchronize_managed_feed
    affiliate.rss_feeds.managed.videos.first.synchronize_youtube_urls! if affiliate.rss_feeds.managed.videos.present?
  end

  def must_have_valid_username
    begin
      doc = Nokogiri::XML(Kernel.open(YoutubeProfile.xml_profile_url(username)))
      errors.add(:username, 'is invalid') if doc.xpath('//xmlns:entry').empty?
    rescue
      errors.add(:username, 'is invalid')
    end
  end
end
