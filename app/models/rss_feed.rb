class RssFeed < ActiveRecord::Base
  include ActiveRecordExtension
  validates_presence_of :name, :affiliate_id
  validate :rss_feed_urls_cannot_be_blank
  after_validation :update_error_keys
  before_save :set_is_video_flag
  belongs_to :affiliate
  has_many :rss_feed_urls, :order => 'url ASC', :dependent => :destroy
  has_many :news_items, :order => "published_at DESC"
  has_one :navigation, :as => :navigable, :dependent => :destroy
  scope :navigable_only, joins(:navigation).where(:navigations => { :is_active => true } )
  scope :govbox_enabled, where(:shown_in_govbox => true)
  scope :managed, where(:is_managed => true)
  scope :videos, where(:is_video => true)
  scope :non_videos, where(:is_video => false)
  attr_protected :is_managed, :is_video
  accepts_nested_attributes_for :rss_feed_urls, :allow_destroy => true, :reject_if => proc { |a| a[:id].blank? and a[:url].blank? }
  accepts_nested_attributes_for :navigation

  def freshen(ignore_older_items = true)
    synchronize_youtube_urls! if is_managed?
    rss_feed_urls(true).reject(&:is_playlist?).each { |u| u.freshen(ignore_older_items) }
    rss_feed_urls.select(&:is_playlist?).sort_by { |url| url.url }.each { |u| u.freshen(ignore_older_items) }
  end

  def synchronize_youtube_urls!
    target_urls = []
    target_urls << affiliate.youtube_profiles.collect(&:url)
    target_urls << query_youtube_playlist_urls
    added_or_existing_urls = []
    transaction do
      target_urls.flatten.each do |url|
        added_or_existing_urls << rss_feed_urls.where(:url => url).first_or_create!
      end
      self.rss_feed_urls = added_or_existing_urls
      destroy if rss_feed_urls.blank?
    end
  end

  def query_youtube_playlist_urls
    youtube_playlist_urls = []
    affiliate.youtube_profiles.collect(&:username).each do |youtube_handle|
      begin
        query_playlists_url = "http://gdata.youtube.com/feeds/api/users/#{youtube_handle}/playlists?start-index=1&max-results=50&v=2"
        playlists_document = Nokogiri::XML(Kernel.open(query_playlists_url))
        playlist_total = playlists_document.xpath("/xmlns:feed/openSearch:totalResults").inner_text.to_f
        youtube_playlist_urls << extract_playlist_urls(playlists_document, (playlist_total / 50).ceil - 1)
      rescue Exception => e
        Rails.logger.warn "Error RssFeed#query_youtube_playlist_urls: #{e.to_s}"
        youtube_playlist_urls = rss_feed_urls(true).select(&:is_playlist?).collect(&:url)
      end
    end
    youtube_playlist_urls.flatten.sort
  end

  def self.refresh_all(freshen_managed_feeds = false)
    all(:conditions => { :is_managed => freshen_managed_feeds }, :order => 'affiliate_id ASC, id ASC').each(&:freshen)
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

  def extract_playlist_urls(playlists_document, extract_counter)
    youtube_playlist_urls = []
    playlists_document.xpath('/xmlns:feed/xmlns:entry').each do |entry|
      playlist_id = entry.xpath('yt:playlistId').inner_text
      playlist_url = "http://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?alt=rss&start-index=1&max-results=50&v=2"
      youtube_playlist_urls << playlist_url
    end
    if extract_counter > 0
      next_query_playlists_url = playlists_document.xpath("/xmlns:feed/xmlns:link[@rel='next'][@type='application/atom+xml'][@href]/@href").first.to_s.strip
      next_playlists_document = Nokogiri::XML(Kernel.open(next_query_playlists_url.to_s.strip))
      youtube_playlist_urls << extract_playlist_urls(next_playlists_document, extract_counter - 1)
    end
    youtube_playlist_urls
  end
end