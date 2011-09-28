class RssFeed < ActiveRecord::Base
  validates_presence_of :url, :name, :affiliate_id
  belongs_to :affiliate
  has_many :news_items, :dependent => :destroy, :order => "published_at DESC"

  def freshen
    most_recently = news_items.present? ? news_items.first.published_at : nil
    Nokogiri::XML(open(url)).xpath('//item').each do |item|
      published_at = DateTime.parse(item.xpath('pubDate').inner_text)
      return if most_recently and published_at < most_recently
      link = item.xpath('link').inner_text
      title = item.xpath('title').inner_text
      guid = item.xpath('guid').inner_text
      description = item.xpath('description').inner_text
      NewsItem.create(:rss_feed => self, :link => link, :title => title, :description => description, :published_at => published_at, :guid => guid) unless news_items.exists?(:guid => guid)
    end
  end

  def self.refresh_all
    all.each(&:freshen)
  end

end