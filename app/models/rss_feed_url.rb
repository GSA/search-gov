class RssFeedUrl < ActiveRecord::Base
  include ActiveRecordExtension
  OK_STATUS = 'OK'
  PENDING_STATUS = 'Pending'
  STATUSES = [OK_STATUS, PENDING_STATUS]
  RSS_ELEMENTS = { "item" => "item", "pubDate" => "pubDate", "link" => "link", "title" => "title", "guid" => "guid", "description" => "description" }
  ATOM_ELEMENTS = { "item" => "xmlns:entry", "pubDate" => "xmlns:updated", "link" => "xmlns:link/@href", "title" => "xmlns:title", "guid" => "xmlns:id", "description" => "xmlns:content" }
  FEED_ELEMENTS = { :rss => RSS_ELEMENTS, :atom => ATOM_ELEMENTS }

  belongs_to :rss_feed
  has_many :news_items, :order => "published_at DESC", :dependent => :destroy
  validates_presence_of :url
  validate :url_must_point_to_a_feed

  def is_video?
    url =~ /^https?:\/\/gdata\.youtube\.com\/feeds\/.+$/i
  end

  def freshen(ignore_older_items = true)
    update_attributes!(:last_crawled_at => Time.current)
    begin
      most_recently = news_items.present? ? news_items.first.published_at : nil
      rss_document = Nokogiri::XML(Kernel.open(url))
      feed_type = detect_feed_type(rss_document)
      if feed_type.nil?
        update_attributes!(:last_crawl_status => "Unknown feed type.")
      else
        rss_document.xpath("//#{FEED_ELEMENTS[feed_type]["item"]}").each do |item|
          published_at = DateTime.parse(item.xpath(FEED_ELEMENTS[feed_type]["pubDate"]).inner_text)
          break if most_recently and published_at < most_recently and ignore_older_items
          link = item.xpath(FEED_ELEMENTS[feed_type]["link"]).inner_text
          title = item.xpath(FEED_ELEMENTS[feed_type]["title"]).inner_text
          guid = item.xpath(FEED_ELEMENTS[feed_type]["guid"]).inner_text
          guid = link if guid.blank?
          raw_description = item.xpath(FEED_ELEMENTS[feed_type]["description"]).inner_text
          description = Nokogiri::HTML(raw_description).inner_text.squish

          unless rss_feed.news_items.exists?(['guid = ? OR link = ?', guid, link])
            news_items.create!(:rss_feed => rss_feed,
                               :link => link,
                               :title => title,
                               :description => description,
                               :published_at => published_at,
                               :guid => guid)
          end
        end
        update_attributes!(:last_crawl_status => OK_STATUS)
      end
    rescue Exception => e
      update_attributes!(:last_crawl_status => e.message)
      Rails.logger.warn(e)
    end
  end

  private
  def url_must_point_to_a_feed
    return unless changed.include?('url')
    set_http_prefix :url
    if url =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
      begin
        rss_doc = Nokogiri::XML(Kernel.open(url))
        errors.add(:url, "does not appear to be a valid RSS feed.") if detect_feed_type(rss_doc).nil?
      rescue Exception => e
        errors.add(:url, "does not appear to be a valid RSS feed. Additional information: " + e.message)
      end
    else
      errors.add(:url, "is invalid")
    end
  end

  def detect_feed_type(document)
    case document.root.name
      when 'feed' then :atom
      when 'rss' then :rss
      else nil
    end
  end
end
