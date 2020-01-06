class YoutubeProfile < ApplicationRecord
  attr_writer :url
  has_one :rss_feed, as: :owner, dependent: :destroy
  has_and_belongs_to_many :affiliates
  has_many :youtube_playlists, -> { order [:updated_at, :id] }, dependent: :destroy

  validates_presence_of :channel_id, :title
  validates_uniqueness_of :channel_id,
                          message: 'has already been added'

  after_create :create_video_rss_feed

  scope :active, -> { joins(:affiliates).distinct }
  scope :stale, -> { where('imported_at IS NULL or imported_at <= ?', Time.current - 1.hour).order(:imported_at) }

  def url
    channel_id? ? "https://www.youtube.com/channel/#{channel_id}" : @url
  end

  private

  def create_video_rss_feed
    unless rss_feed
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_youtube_profile.where(url: url).first_or_create!
      create_rss_feed!(name: channel_id, rss_feed_urls: [rss_feed_url])
    end
  end
end
