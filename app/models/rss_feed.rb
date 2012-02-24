class RssFeed < ActiveRecord::Base
  validates_presence_of :url, :name, :affiliate_id
  validate :is_valid_rss_feed?, :on => :create
  belongs_to :affiliate
  has_many :news_items, :dependent => :destroy, :order => "published_at DESC"
  RSS_ELEMENTS = { "item" => "item", "pubDate" => "pubDate", "link" => "link", "title" => "title", "guid" => "guid", "description" => "description" }
  ATOM_ELEMENTS = { "item" => "xmlns:entry", "pubDate" => "xmlns:published", "link" => "xmlns:link/@href", "title" => "xmlns:title", "guid" => "xmlns:id", "description" => "xmlns:content" }
  FEED_ELEMENTS = { :rss => RSS_ELEMENTS, :atom => ATOM_ELEMENTS }

  def freshen(ignore_older_items = true)
    self.update_attributes(:last_crawled_at => Time.now)
    begin
      most_recently = news_items.present? ? news_items.first.published_at : nil
      rss_document = Nokogiri::XML(open(url))
      feed_type = detect_feed_type(rss_document)
      if feed_type.nil?
        self.update_attributes(:last_crawl_status => "Unkown feed type.")
      else
        rss_document.xpath("//#{FEED_ELEMENTS[feed_type]["item"]}").each do |item|
          published_at = DateTime.parse(item.xpath(FEED_ELEMENTS[feed_type]["pubDate"]).inner_text)
          break if most_recently and published_at < most_recently and ignore_older_items
          link = item.xpath(FEED_ELEMENTS[feed_type]["link"]).inner_text
          title = item.xpath(FEED_ELEMENTS[feed_type]["title"]).inner_text
          guid = item.xpath(FEED_ELEMENTS[feed_type]["guid"]).inner_text
          raw_description = item.xpath(FEED_ELEMENTS[feed_type]["description"]).inner_text
          description = Nokogiri::HTML(raw_description).inner_text.gsub(/[\t\n\r]/, ' ').squish
          NewsItem.create!(:rss_feed => self, :link => link, :title => title, :description => description, :published_at => published_at, :guid => guid) unless news_items.exists?(:guid => guid)
        end
        self.update_attributes(:last_crawl_status => "OK")
      end
    rescue Exception => e
      self.update_attributes(:last_crawl_status => e.message)
      Rails.logger.warn(e)
    end
  end

  def self.refresh_all
    all.each(&:freshen)
  end

  private

  def is_valid_rss_feed?
    unless url =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
      errors.add(:url, "The URL entered is not a valid URL.")
    else
      begin
        rss_doc = Nokogiri::XML(Kernel.open(url))
        errors.add(:url, "The RSS feed URL specified does not appear to be a valid RSS feed.") unless %{rss feed}.include?(rss_doc.root.name)
      rescue Exception => e
        errors.add(:url, "The RSS feed URL specified does not appear to be a valid RSS feed.  Additional information: " + e.message)
      end
    end
  end

  def detect_feed_type(document)
    document.root.name == "feed" ? :atom : :rss
  end
end