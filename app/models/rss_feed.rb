class RssFeed < ActiveRecord::Base
  validates_presence_of :url, :name, :affiliate_id
  validate :is_valid_rss_feed?
  belongs_to :affiliate
  has_many :news_items, :dependent => :destroy, :order => "published_at DESC"

  def freshen
    most_recently = news_items.present? ? news_items.first.published_at : nil
    Nokogiri::XML(open(url)).xpath('//item').each do |item|
      published_at = DateTime.parse(item.xpath('pubDate').inner_text)
      break if most_recently and published_at < most_recently
      link = item.xpath('link').inner_text
      title = item.xpath('title').inner_text
      guid = item.xpath('guid').inner_text
      raw_description = item.xpath('description').inner_text
      description = Nokogiri::HTML(raw_description).inner_text.gsub(/[\t\n\r]/, ' ').squish
      NewsItem.create(:rss_feed => self, :link => link, :title => title, :description => description, :published_at => published_at, :guid => guid) unless news_items.exists?(:guid => guid)
    end
    Sunspot.commit
  end

  def self.refresh_all
    all.each(&:freshen)
  end
  
  private
  
  def is_valid_rss_feed?
    unless url =~  /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
      errors.add(:url, "The URL entered is not a valid URL.")
    else
      begin
        errors.add(:url, "The RSS feed URL specified does not appear to be a valid RSS feed.") if Nokogiri::XML(Kernel.open(url)).xpath('//channel').empty?
      rescue Exception => e
        errors.add(:url, "The RSS feed URL specified does not appear to be a valid RSS feed.  Additional information: " + e.message)
      end
    end
  end  
end