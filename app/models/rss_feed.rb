class RssFeed < ActiveRecord::Base
  include ActiveRecordExtension
  validates_presence_of :name, :affiliate_id
  validate :rss_feed_urls_cannot_be_blank
  after_validation :update_error_keys
  before_save :set_is_video_flag
  belongs_to :affiliate
  has_many :rss_feed_urls, :order => 'url ASC', :dependent => :destroy
  has_many :news_items, :order => "published_at DESC"
  scope :navigable_only, where(:is_navigable => true)
  scope :govbox_enabled, where(:shown_in_govbox => true)
  scope :managed, where(:is_managed => true)
  scope :videos, where(:is_video => true)
  scope :non_videos, where(:is_video => false)
  attr_protected :is_managed, :is_video
  accepts_nested_attributes_for :rss_feed_urls, :allow_destroy => true, :reject_if => proc { |a| a[:id].blank? and a[:url].blank? }

  def freshen(ignore_older_items = true)
    rss_feed_urls.each { |u| u.freshen(ignore_older_items) }
  end

  def self.refresh_all
    all.each(&:freshen)
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