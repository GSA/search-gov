class RssFeedUrl < ActiveRecord::Base
  include ActiveRecordExtension
  OK_STATUS = 'OK'
  PENDING_STATUS = 'Pending'
  STATUSES = [OK_STATUS, PENDING_STATUS]

  attr_readonly :rss_feed_owner_type, :url
  has_and_belongs_to_many :rss_feeds
  has_many :news_items, order: 'published_at DESC', dependent: :destroy

  before_validation :normalize_url, on: :create

  validates_presence_of :rss_feed_owner_type, :url
  validates_uniqueness_of :url, scope: :rss_feed_owner_type, case_sensitive: false
  validate :url_must_point_to_a_feed, on: :create

  scope :active, joins(:rss_feeds).uniq
  scope :rss_feed_owned_by_affiliate, where(rss_feed_owner_type: Affiliate.name)
  scope :rss_feed_owned_by_youtube_profile, where(rss_feed_owner_type: YoutubeProfile.name)

  def self.refresh_affiliate_feeds
    RssFeedUrl.rss_feed_owned_by_affiliate.active.each(&:freshen)
  end

  def freshen(ignore_older_items = true)
    Resque.enqueue_with_priority(:high, RssFeedFetcher, id, ignore_older_items) if rss_feed_owner_type == 'Affiliate'
  end

  def is_video?
    url =~ /^https?:\/\/gdata\.youtube\.com\/feeds\/.+$/i
  end

  def self.find_existing_or_initialize(url)
    normalized_url = UrlParser.normalize url
    return new(url: url) unless normalized_url

    url_without_protocol = normalized_url.sub(/^https?:\/\//i, '')
    where('(url = ? OR url = ?)',
          "http://#{url_without_protocol}",
          "https://#{url_without_protocol}").first_or_initialize do |u|
      u.url = normalized_url
    end
  end

  private

  def normalize_url
    normalized_url = UrlParser.normalize url
    self.url = normalized_url if normalized_url
  end

  def url_must_point_to_a_feed
    if url =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
      begin
        rss_doc = Nokogiri::XML(HttpConnection.get(url))
        errors.add(:url, "does not appear to be a valid RSS feed.") unless rss_doc && %w(feed rss).include?(rss_doc.root.name)
      rescue Exception => e
        errors.add(:url, "does not appear to be a valid RSS feed. Additional information: " + e.message)
      end
    else
      errors.add(:url, "is invalid")
    end
  end
end
