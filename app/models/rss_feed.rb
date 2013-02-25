class RssFeed < ActiveRecord::Base
  include ActiveRecordExtension
  validates_presence_of :name, :affiliate_id
  validate :rss_feed_urls_cannot_be_blank
  after_validation :update_error_keys
  before_save :set_is_video_flag
  belongs_to :affiliate
  has_many :rss_feed_urls, :order => 'url ASC, id ASC', :dependent => :destroy
  has_many :news_items, order: 'published_at DESC', dependent: :destroy
  has_one :navigation, :as => :navigable, :dependent => :destroy
  scope :navigable_only, joins(:navigation).where(:navigations => { :is_active => true } )
  scope :govbox_enabled, where(:shown_in_govbox => true)
  scope :managed, where(:is_managed => true)
  scope :videos, where(:is_video => true)
  scope :non_videos, where(:is_video => false)
  scope :updated_before, lambda { |time| where('updated_at < ?', time).order('updated_at asc, id asc') }
  attr_protected :is_managed, :is_video
  accepts_nested_attributes_for :rss_feed_urls, :allow_destroy => true, :reject_if => proc { |a| a[:id].blank? and a[:url].blank? }
  accepts_nested_attributes_for :navigation

  def freshen(ignore_older_items = true)
    Resque.enqueue_with_priority(:high, RssFeedFetcher, id, nil, ignore_older_items)
  end

  def self.refresh_managed_feeds(max_news_items_enqueued = 3000)
    feeds = managed.updated_before(30.minutes.ago)
    news_items_enqueued = 0
    feed_to_enqueue = []
    feeds.each do |f|
      count = f.news_items.count
      if news_items_enqueued == 0
        news_items_enqueued += count
        feed_to_enqueue << f
      elsif (count + news_items_enqueued) < max_news_items_enqueued
        news_items_enqueued += count
        feed_to_enqueue << f
      elsif news_items_enqueued >= max_news_items_enqueued
        break
      end
    end
    if feed_to_enqueue.present?
      feed_to_enqueue.each(&:touch)
      Resque.enqueue_with_priority(:high, RssFeedFetcher, feed_to_enqueue.collect(&:id))
    end
  end

  def self.refresh_non_managed_feeds
    where(is_managed: false).order('id asc').each(&:freshen)
  end

  def is_video?
    self.is_video
  end

  private
  def rss_feed_urls_cannot_be_blank
    errors.add(:base, "RSS feed must have 1 or more URLs.") if rss_feed_urls.blank? or rss_feed_urls.all?(&:marked_for_destruction?)
  end

  def update_error_keys
    swap_error_key(:"rss_feed_urls.url", :rss_feed_url)
  end

  def set_is_video_flag
    self.is_video = rss_feed_urls.present? && rss_feed_urls.all?(&:is_video?)
    true
  end
end