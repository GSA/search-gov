# frozen_string_literal: true

class NewsItem < ApplicationRecord
  include FastDeleteFromDbAndEs

  before_validation do |record|
    AttributeProcessor.squish_attributes(record,
                                         :body,
                                         :contributor,
                                         :description,
                                         :guid,
                                         :link,
                                         :publisher,
                                         :subject,
                                         :title,
                                         assign_nil_on_blank: true)
  end

  before_validation :downcase_scheme
  validates :title, :link, :published_at, :guid, :rss_feed_url_id, presence: true
  validates :description, presence: { unless: :description_not_required? }
  validates_url :link
  validates :guid, uniqueness: {
    scope: :rss_feed_url_id,
    case_sensitive: false
  }
  validates :link, uniqueness: {
    scope: :rss_feed_url_id,
    case_sensitive: false
  }
  validate :unique_link
  belongs_to :rss_feed_url
  serialize :properties, Hash
  store_accessor :properties, :duration

  alias_attribute :url, :link

  def is_video?
    link =~ %r{\Ahttps?://www\.youtube\.com/watch\?v=}
  end

  # Historically, the image-related "properties" supported images from MRSS feeds.
  # That was deprecated when ASIS was released, but we still need
  # to switch one admin center preview to ASIS: https://cm-jira.usa.gov/browse/SRCH-2615.
  # When that is done, we can remove any code related to image properties.
  # The 'duration' property is still used for videos.
  def tags
    if properties.key?(:media_content) and
       properties[:media_content][:url].present? and
       properties.key?(:media_thumbnail) and
       properties[:media_thumbnail][:url].present?
      %w[image]
    else
      []
    end
  end

  def thumbnail_url
    properties[:media_thumbnail][:url] if properties[:media_thumbnail]
  end

  # This method should be removed entirely per SRCH-3465. It is temporary
  # code to prevent video searches from failing during deployment of SRCH-3718.
  def duration
    if properties.is_a?(String)
      JSON.parse(properties)['duration']
    else
      properties.with_indifferent_access[:duration]
    end
  end

  def language
    rss_feed_url.language || owner_language_guess
  end

  def owner_language_guess
    first_feed = rss_feed_url.rss_feeds.first
    first_feed.owner_type == 'Affiliate' ? first_feed.owner.indexing_locale : first_feed.owner.affiliates.first.indexing_locale
  rescue Exception => e
    Rails.logger.warn "NewsItem #{self.id} is not associated with any RssFeed: #{e}"
    'en'
  end

  def youtube_thumbnail_url
    video_id = CGI.parse(URI.parse(link).query)['v'].first
    "https://i.ytimg.com/vi/#{video_id}/default.jpg"
  end

  private

  def unique_link
    link_without_protocol = UrlParser.strip_http_protocols(link)
    conditions = ['((link = ? OR link = ?))',
                  "http://#{link_without_protocol}",
                  "https://#{link_without_protocol}"]
    id_conditions = persisted? ? ['id != ?', id] : []
    if rss_feed_url && rss_feed_url.news_items.where(conditions).where(id_conditions).any?
      errors.add(:link, 'has already been taken')
    end
  end

  def description_not_required?
    is_video? || body?
  end

  def downcase_scheme
    self.link = link.sub('HTTP', 'http').sub('httpS', 'https') if link.present?
  end
end
