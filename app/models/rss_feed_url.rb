class RssFeedUrl < ActiveRecord::Base
  include ActiveRecordExtension
  OK_STATUS = 'OK'
  PENDING_STATUS = 'Pending'
  STATUSES = [OK_STATUS, PENDING_STATUS]

  attr_readonly :rss_feed_owner_type
  attr_accessor :current_url
  has_and_belongs_to_many :rss_feeds, join_table: :rss_feed_urls_rss_feeds
  has_many :news_items, -> { order 'published_at DESC' }
  before_destroy :blocking_destroy_news_items

  before_validation NormalizeUrl.new(:url), on: :create

  validates_presence_of :rss_feed_owner_type, :url
  validates_uniqueness_of :url, scope: :rss_feed_owner_type, case_sensitive: false
  validate :url_must_point_to_a_feed, if: :url_changed?
  validate :url_is_readonly, on: :update, if: :url_changed?

  scope :active, -> { joins(:rss_feeds).uniq }
  scope :inactive, -> { includes(:rss_feeds).references(:rss_feeds).where('rss_feeds.id IS NULL') }
  scope :rss_feed_owned_by_affiliate, -> { where(rss_feed_owner_type: Affiliate.name) }
  scope :rss_feed_owned_by_youtube_profile, -> { where(rss_feed_owner_type: YoutubeProfile.name) }

  def self.refresh_affiliate_feeds
    RssFeedUrl.rss_feed_owned_by_affiliate.active.each(&:freshen)
  end

  def freshen(ignore_older_items = true)
    Resque.enqueue(RssFeedFetcher, id, ignore_older_items) if rss_feed_owner_type == 'Affiliate'
  end

  def self.enqueue_destroy_all_inactive
    rss_feed_owned_by_affiliate.inactive.each(&:enqueue_destroy_inactive)
  end

  def enqueue_destroy_inactive
    Resque.enqueue_with_priority(:low, InactiveRssFeedUrlDestroyer, id)
  end

  def self.enqueue_destroy_all_news_items_with_404
    enqueue_destroy_all_news_items_with_404_by_hosts unique_non_throttled_hosts
    enqueue_destroy_all_news_items_with_404_by_hosts throttled_hosts, true
  end

  def self.unique_non_throttled_hosts
    unique_hosts(RssFeedUrl.rss_feed_owned_by_affiliate.active) - throttled_hosts
  end

  def self.throttled_hosts
    Rails.application.secrets.throttled_rss_feed_hosts || []
  end

  def self.enqueue_destroy_all_news_items_with_404_by_hosts(hosts, is_throttled = false)
    hosts.each do |host|
      rss_feed_url_ids = RssFeedUrl.rss_feed_owned_by_affiliate.active.where('url LIKE ?', "%#{host}%").pluck(:id)
      Resque.enqueue_with_priority(:low, NewsItemsChecker, rss_feed_url_ids, is_throttled)
    end
  end

  def self.unique_hosts(rss_feed_urls)
    domains = Set.new
    rss_feed_urls.each do |rss_feed_url|
      normalized_host = UrlParser.normalize_host(rss_feed_url.url)
      domains.add normalized_host if normalized_host
    end
    domains.to_a.sort
  end

  def enqueue_destroy_news_items_with_404(priority = :low)
    Resque.enqueue_with_priority(priority, NewsItemsChecker, id) if rss_feed_owner_type == 'Affiliate'
  end

  def enqueue_destroy_news_items(priority = :low)
    Resque.enqueue_with_priority(priority, NewsItemsDestroyer, id) if rss_feed_owner_type == 'Affiliate'
  end

  def is_video?
    url =~ %r[\A(https?://gdata\.youtube\.com/feeds/|https?://www\.youtube\.com/channel/)]i &&
      YoutubeProfile.name == rss_feed_owner_type
  end

  def self.find_existing_or_initialize(url)
    normalized_url = UrlParser.normalize url
    return new(url: url) unless normalized_url

    url_without_protocol = UrlParser.strip_http_protocols normalized_url
    where('(url = ? OR url = ?)',
          "http://#{url_without_protocol}",
          "https://#{url_without_protocol}").first_or_initialize do |u|
      u.url = normalized_url
    end
  end

  def to_label
    url
  end

  def self.find_parent_rss_feed_name(affiliate, id)
    rss_feed = RssFeed.owned_by_affiliate.joins(:rss_feed_urls).
      where(owner_id: affiliate.id, 'rss_feed_urls.id' => id).first
    rss_feed.name if rss_feed
  end

  def document
    @document ||= RssDocument.new(response[:body]) unless ( redirected? && !(protocol_redirect?) )
  end

  def current_url
    response[:last_effective_url] || url
  end

  def redirected?
    url != current_url
  end

  def protocol_redirect?
    redirected? && urls_match_without_protocol(current_url, url)
  end

  private

  def response
    @response ||= begin
                    DocumentFetchLogger.new(url, 'rss_feed').log
                    DocumentFetcher.fetch(url, connect_timeout: 20, read_timeout: 50)
                  end
  end

  def url_must_point_to_a_feed
    return true if is_video?

    if url =~ /(\A\z)|(\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?\z)/ix
      begin
        document.valid? ? self.language = document.language : errors.add(:url, "does not appear to be a valid RSS feed.")
      rescue Exception => e
        errors.add(:url, "does not appear to be a valid RSS feed. Additional information: " + e.message)
      end
    else
      errors.add(:url, "is invalid")
    end
  end

  def url_is_readonly
    unless urls_match_without_protocol(url, url_was)
      errors.add(:url, "is read-only except for a protocol change")
    end
  end

  def urls_match_without_protocol(url1, url2)
    UrlParser.strip_http_protocols(url1) == UrlParser.strip_http_protocols(url2)
  end

  def blocking_destroy_news_items
    NewsItemsDestroyer.perform(id)
  end
end
