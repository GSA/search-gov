require 'rss'

class RssFeedUrl < ActiveRecord::Base
  include ActiveRecordExtension
  OK_STATUS = 'OK'
  PENDING_STATUS = 'Pending'
  STATUSES = [OK_STATUS, PENDING_STATUS]

  belongs_to :rss_feed
  has_many :news_items, :order => "published_at DESC", :dependent => :destroy
  validates_presence_of :url
  validate :url_must_point_to_a_feed

  def is_video?
    url =~ /^https?:\/\/gdata\.youtube\.com\/feeds\/.+$/i
  end

  private

  def url_must_point_to_a_feed
    return unless changed.include?('url')
    set_http_prefix :url
    if url =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
      begin
        rss_doc = Nokogiri::XML(get_feed(url))
        errors.add(:url, "does not appear to be a valid RSS feed.") unless rss_doc && %w(feed rss).include?(rss_doc.root.name)
      rescue Exception => e
        errors.add(:url, "does not appear to be a valid RSS feed. Additional information: " + e.message)
      end
    else
      errors.add(:url, "is invalid")
    end
  end

  def get_feed(url)
    if url =~ %r[https?://gdata\.youtube\.com/]i
      YoutubeConnection.get(url)
    else
      Kernel.open(url)
    end
  end
end
