# frozen_string_literal: true

class NewsItem < ApplicationRecord
  include FastDeleteFromDbAndEs
  include AttrJson::Record

  attr_json :media_content, ActiveModel::Type::Value.new, container_attribute: 'properties'
  attr_json :media_thumbnail, ActiveModel::Type::Value.new, container_attribute: 'properties'
  attr_json :duration, :string, container_attribute: 'properties'

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

  alias_attribute :url, :link

  def is_video?
    link =~ %r{\Ahttps?://www\.youtube\.com/watch\?v=}
  end

  def tags
    if media_content.present? &&
       media_content['url'] &&
       media_thumbnail.present? &&
       media_thumbnail['url']
      %w[image]
    else
      []
    end
  end

  def thumbnail_url
    media_thumbnail['url']
  end

  def language
    rss_feed_url.language || owner_language_guess
  end

  def owner_language_guess
    first_feed = rss_feed_url.rss_feeds.first
    first_feed.owner_type == 'Affiliate' ? first_feed.owner.indexing_locale : first_feed.owner.affiliates.first.indexing_locale
  rescue Exception => e
    Rails.logger.warn "NewsItem #{id} is not associated with any RssFeed: #{e}"
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
