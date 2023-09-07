class RssDocument
  include ActiveModel::Validations

  validate :is_rss

  attr_reader :xml

  def initialize(document)
    # This is very old code that could eventually be refactored to use Feedjira
    @xml = Nokogiri.XML(document)
  end

  def feed_type
    case xml.root.name
      when 'feed' then
        :atom
      when 'rss' then
        :rss
    end
  end

  def language
    lang = xml.xpath('//language').inner_text.downcase rescue nil
    lang.present? ? lang.first(2) : nil
  end

  def elements
    feed_elements[feed_type]
  end

  def items
    xml.xpath("//#{elements[:item]}")
  end

  private

  def is_rss
    errors.add(:base, 'invalid rss') if %w(feed rss).exclude?(xml.root.try(:name))
  end

  def rss_elements
    { item: 'item',
      body: 'content:encoded',
      pubDate: %w(pubDate),
      link: %w(link),
      title: 'title',
      guid: 'guid',
      contributor: './/dc:contributor',
      publisher: './/dc:publisher',
      subject: './/dc:subject',
      description: %w(description),
      media_content: './/media:content[@url]',
      media_description: './media:description',
      media_text: './/media:text',
      media_thumbnail_url: './/media:thumbnail/@url' }.freeze
  end

  def atom_elements
    { item: 'xmlns:entry',
      pubDate: %w(xmlns:updated xmlns:published),
      link: %w(xmlns:link[@rel='alternate'][@href]/@href xmlns:link/@href),
      title: 'xmlns:title',
      guid: 'xmlns:id',
      description: %w(xmlns:content xmlns:summary) }.freeze
  end

  def feed_elements
    { rss: rss_elements, atom: atom_elements }.freeze
  end
end
