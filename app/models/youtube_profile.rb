class YoutubeProfile < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :username, :affiliate
  validates_uniqueness_of :username, :scope => :affiliate_id
  
  before_validation :normalize_username
  after_create :create_video_rss_feed
  after_update :update_video_rss_feed
  after_destroy :destroy_video_rss_feed
  
  class << self
    
    def youtube_url(username)
      url_params = ActiveSupport::OrderedHash.new
      url_params[:alt] = 'rss'
      url_params[:author] = username
      url_params[:orderby] = 'published'
      "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}".downcase
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
    unless self.affiliate.rss_feeds.collect(&:rss_feed_urls).flatten.collect(&:url).include?(url)
      rss_feed = self.affiliate.rss_feeds.find_or_initialize_by_name_and_is_managed('Videos', true)
      rss_feed.is_managed = true
      rss_feed.rss_feed_urls.build(:url => url)
      rss_feed.save!
    end
  end
  
  def update_video_rss_feed
    if self.username_changed?
      rss_feed = self.affiliate.rss_feeds.find_by_name_and_is_managed('Videos', true)
      if rss_feed
        old_feed = rss_feed.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url(self.username_was))
        old_feed.destroy if old_feed
      end
      create_video_rss_feed
    end
  end
  
  def destroy_video_rss_feed
    rss_feed = self.affiliate.rss_feeds.find_by_name_and_is_managed('Videos', true)
    if rss_feed
      rss_feed_url = rss_feed.rss_feed_urls.find_by_url(self.url)
      if rss_feed_url
        if rss_feed.rss_feed_urls.count == 1
          rss_feed.destroy
        else
          rss_feed_url.destroy
        end
      end
    end
  end
end
