class NewsItem < ActiveRecord::Base
  extend AttributeSquisher
  include FastDeleteFromDbAndEs

  before_validation_squish :body, :contributor, :description, :guid, :link,
                           :publisher, :subject, :title,
                           assign_nil_on_blank: true
  before_validation :downcase_scheme
  validates_presence_of :title, :link, :published_at, :guid, :rss_feed_url_id
  validates_presence_of :description, unless: :description_not_required?
  validates_url :link
  validates_uniqueness_of :guid, scope: :rss_feed_url_id, :case_sensitive => false
  validates_uniqueness_of :link, scope: :rss_feed_url_id, :case_sensitive => false
  belongs_to :rss_feed_url
  serialize :properties, Hash

  alias_attribute :url, :link

  TIME_BASED_SEARCH_OPTIONS = ActiveSupport::OrderedHash.new
  TIME_BASED_SEARCH_OPTIONS["h"] = :hour
  TIME_BASED_SEARCH_OPTIONS["d"] = :day
  TIME_BASED_SEARCH_OPTIONS["w"] = :week
  TIME_BASED_SEARCH_OPTIONS["m"] = :month
  TIME_BASED_SEARCH_OPTIONS["y"] = :year

  def is_video?
    link =~ /^#{Regexp.escape('http://www.youtube.com/watch?v=')}.+/i
  end

  def tags
    if properties.key?(:media_content) and
        properties[:media_content][:url].present? and
        properties.key?(:media_thumbnail) and
        properties[:media_thumbnail][:url].present?
      %w(image)
    else
      []
    end
  end

  def thumbnail_url
    properties[:media_thumbnail][:url] if properties[:media_thumbnail]
  end

  def duration
    properties[:duration]
  end

  def duration=(duration_str)
    properties[:duration] = duration_str
  end

  def language
    rss_feed_url.language || owner_language_guess
  end

  def owner_language_guess
    first_feed = rss_feed_url.rss_feeds.first
    first_feed.owner_type == 'Affiliate' ? first_feed.owner.locale : first_feed.owner.affiliates.first.locale
  rescue Exception => e
    Rails.logger.warn "NewsItem #{self.id} is not associated with any RssFeed: #{e}"
    'en'
  end

  def youtube_thumbnail_url
    video_id = CGI.parse(URI.parse(link).query)['v'].first
    "https://i.ytimg.com/vi/#{video_id}/default.jpg"
  end

  private

  def description_not_required?
    is_video? || body?
  end

  def downcase_scheme
    self.link = link.sub('HTTP','http').sub('httpS','https') if link.present?
  end
end
