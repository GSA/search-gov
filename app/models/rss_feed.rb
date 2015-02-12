class RssFeed < ActiveRecord::Base
  include ActiveRecordExtension
  validates_presence_of :name, :owner_id, :owner_type
  validate :rss_feed_urls_cannot_be_blank
  after_validation :update_error_keys

  before_save :set_is_video_flag
  belongs_to :owner, polymorphic: true
  has_and_belongs_to_many :rss_feed_urls, order: 'url ASC, id ASC'
  has_many :news_items, through: :rss_feed_urls, uniq: true
  has_one :navigation, :as => :navigable, :dependent => :destroy

  scope :navigable_only, joins(:navigation).where(:navigations => { :is_active => true } )
  scope :managed, where(:is_managed => true)
  scope :videos, where(:is_video => true)
  scope :non_managed, where(is_managed: false)
  scope :non_mrss, where(show_only_media_content: false)
  scope :mrss, where(show_only_media_content: true)
  scope :updated_before, lambda { |time| where('updated_at < ?', time).order('updated_at asc, id asc') }
  scope :owned_by_affiliate, where(owner_type: 'Affiliate')
  scope :owned_by_youtube_profile, where(owner_type: 'YoutubeProfile')
  attr_readonly :is_managed
  attr_protected :is_video
  accepts_nested_attributes_for :rss_feed_urls
  accepts_nested_attributes_for :navigation

  def has_errors?
    rss_feed_urls.where("last_crawl_status NOT IN (?)",RssFeedUrl::STATUSES).any?
  end

  def has_pending?
    rss_feed_urls.where(last_crawl_status: RssFeedUrl::PENDING_STATUS).any?
  end

  def self.youtube_profile_rss_feeds_by_site(site)
    youtube_profile_ids = site.youtube_profile_ids
    return unless youtube_profile_ids.present?

    RssFeed.includes(:rss_feed_urls).
      owned_by_youtube_profile.
      where(owner_id: youtube_profile_ids)
  end

  private
  def rss_feed_urls_cannot_be_blank
    errors.add(:base, 'RSS feed must have 1 or more URLs.') if !is_managed? and rss_feed_urls.blank? || rss_feed_urls.all?(&:marked_for_destruction?)
  end

  def update_error_keys
    swap_error_key(:"rss_feed_urls.url", :rss_feed_url)
  end

  def set_is_video_flag
    self.is_video = rss_feed_urls.present? && rss_feed_urls.all?(&:is_video?)
    true
  end
end
