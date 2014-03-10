class RssFeedData
  RSS_FEED_OWNER_TYPE = 'Affiliate'.freeze

  RSS_ELEMENTS = { item: 'item',
                   pubDate: %w(pubDate),
                   link: %w(link),
                   title: 'title',
                   guid: 'guid',
                   contributor: 'dc:contributor',
                   publisher: 'dc:publisher',
                   subject: 'dc:subject',
                   description: 'description',
                   media_content: './/media:content[@url]',
                   media_description: './media:description',
                   media_thumbnail_url: './/media:thumbnail/@url' }.freeze

  ATOM_ELEMENTS = { item: 'xmlns:entry',
                    pubDate: %w(xmlns:published xmlns:updated),
                    link: %w(xmlns:link[@rel='alternate'][@href]/@href xmlns:link/@href),
                    title: 'xmlns:title',
                    guid: 'xmlns:id',
                    description: 'xmlns:content' }.freeze

  FEED_ELEMENTS = { rss: RSS_ELEMENTS, atom: ATOM_ELEMENTS }.freeze

  def initialize(rss_feed_url, ignore_older_items = true)
    @rss_feed_url = rss_feed_url
    @ignore_older_items = ignore_older_items
  end

  def import
    @rss_feed_url.touch(:last_crawled_at)
    doc = Nokogiri::XML(HttpConnection.get(@rss_feed_url.url))

    feed_type = detect_feed_type(doc)
    if feed_type.nil?
      @rss_feed_url.update_attributes!(last_crawl_status: 'Unknown feed type.')
      return
    end

    @feed_elements = FEED_ELEMENTS[feed_type]
    extract_news_items(doc)
    @rss_feed_url.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS)
  rescue Exception => e
    Rails.logger.warn(e)
    @rss_feed_url.update_attributes!(last_crawl_status: e.message)
  end

  def detect_feed_type(document)
    case document.root.name
    when 'feed' then :atom
    when 'rss' then :rss
    end
  end

  def self.extract_language(rss_doc)
    lang = rss_doc.xpath('//language').inner_text.downcase rescue nil
    lang.present? ? lang.first(2) : nil
  end

  private

  def extract_news_items(doc)
    @has_media_ns = doc.namespaces['xmlns:media'].present?
    most_recently = @rss_feed_url.news_items.present? ? @rss_feed_url.news_items.first.published_at : nil

    doc.xpath("//#{@feed_elements[:item]}").each do |item|
      published_at = extract_published_at(item)
      next unless published_at.present?
      break if most_recently and published_at < most_recently and @ignore_older_items

      link = extract_link(item)
      next unless link.present?

      attributes = { link: link, published_at: published_at }.
          reverse_merge(extract_other_attributes(item))
      attributes[:guid] = link if attributes[:guid].blank?

      news_item = @rss_feed_url.news_items.
          where('guid = :guid OR link = :link', guid: attributes[:guid], link: link).
          first_or_initialize

      if link_status_code_404?(link)
        news_item.destroy unless news_item.new_record?
        next
      end

      news_item.assign_attributes attributes
      unless news_item.save
        Rails.logger.error "news_item: #{news_item.errors.full_messages}"
      end
    end
  end

  def extract_published_at(item)
    published_at = nil
    @feed_elements[:pubDate].each do |pub_date_path|
      published_at_str = item.xpath(pub_date_path).inner_text
      next if published_at_str.blank?
      published_at = DateTime.parse published_at_str
      break if published_at.present?
    end
    published_at
  end

  def extract_link(item)
    link = nil
    @feed_elements[:link].each do |link_path|
      link = item.xpath(link_path).inner_text
      break if link.present?
    end
    link.squish if link.present?
  end

  def extract_other_attributes(item)
    attributes = extract_elements(item,
                                  :guid, :title,
                                  :contributor, :publisher, :subject)
    attributes[:description] = extract_description(item)
    attributes[:properties] = extract_properties(item) if @has_media_ns
    attributes
  end

  def link_status_code_404?(link)
    UrlStatusCodeFetcher.fetch(link)[link] =~ /404/
  end

  def extract_description(item)
    raw_description = extract_element_content(item, :description)
    description = nil
    description = Sanitize.clean(raw_description).squish if raw_description

    if description.blank? and @has_media_ns
      media_description = extract_element_content(item, :media_description)
      description = Sanitize.clean(media_description).squish if media_description
    end
    description
  end

  def extract_properties(item)
    media_content_node = item.xpath(@feed_elements[:media_content]).first
    return unless media_content_node
    properties = {}

    media_content_url = extract_node_attribute(media_content_node, :url)
    if media_content_url.present?
      media_content_props = { url: media_content_url }
      media_content_type = extract_node_attribute(media_content_node, :type)
      media_content_type ||= UrlParser.mime_type(media_content_url)
      media_content_props[:type] = media_content_type if media_content_type
      properties[:media_content] = media_content_props

      media_thumbnail_url = extract_element_content(media_content_node, :media_thumbnail_url)
      media_thumbnail_url ||= extract_element_content(item, :media_thumbnail_url)
      properties[:media_thumbnail] = { url: media_thumbnail_url } if media_thumbnail_url
    end

    properties
  end

  def extract_elements(item, *elements)
    Hash[elements.map { |element| [element, extract_element_content(item, element)] }]
  end

  def extract_element_content(item, element)
    node = item.xpath(@feed_elements[element]).first
    node.present? && (content = node.inner_text.to_s.squish).present? ? content : nil
  end

  def extract_node_attribute(node, attribute)
    attr_value = node.attr(attribute)
    attr_value.squish if attr_value.present?
  end
end
