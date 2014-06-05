class RssFeedData
  include RssFeedParser

  RSS_FEED_OWNER_TYPE = 'Affiliate'.freeze

  RSS_ELEMENTS = { item: 'item',
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
                   media_thumbnail_url: './/media:thumbnail/@url' }.freeze

  ATOM_ELEMENTS = { item: 'xmlns:entry',
                    pubDate: %w(xmlns:published xmlns:updated),
                    link: %w(xmlns:link[@rel='alternate'][@href]/@href xmlns:link/@href),
                    title: 'xmlns:title',
                    guid: 'xmlns:id',
                    description: %w(xmlns:content xmlns:summary) }.freeze

  FEED_ELEMENTS = { rss: RSS_ELEMENTS, atom: ATOM_ELEMENTS }.freeze

  NAMESPACE_URL_HASH = {
      dc: 'http://purl.org/dc/elements/1.1/',
      media: 'http://search.yahoo.com/mrss/'
  }.freeze

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
    detect_namespaces doc
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

  def detect_namespaces(doc)
    @has_dc_ns = doc.namespaces.values.include?(NAMESPACE_URL_HASH[:dc])
    @has_media_ns = doc.namespaces.values.include?(NAMESPACE_URL_HASH[:media])
  end

  def extract_news_items(doc)
    most_recently = @rss_feed_url.news_items.present? ? @rss_feed_url.news_items.first.published_at : nil

    doc.xpath("//#{@feed_elements[:item]}").each do |item|
      published_at = extract_published_at @feed_elements[:pubDate], item
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

      next if !news_item.new_record? && news_item.published_at >= published_at

      news_item.assign_attributes attributes
      unless news_item.save
        Rails.logger.error "news_item: #{news_item.errors.full_messages}"
      end
    end
  end

  def extract_link(item)
    link = nil
    @feed_elements[:link].each do |link_path|
      break if (link = extract_element_content item, link_path)
    end
    link.squish if link
  end

  def extract_other_attributes(item)
    attributes = extract_elements(item, :guid, :title)
    attributes.merge!(extract_elements(item, :contributor, :publisher, :subject)) if @has_dc_ns
    attributes[:description] = extract_description(item)
    attributes[:properties] = extract_properties(item) if @has_media_ns
    attributes
  end

  def link_status_code_404?(link)
    UrlStatusCodeFetcher.fetch(link)[link] =~ /404/
  end

  def extract_description(item)
    raw_description = nil
    @feed_elements[:description].each do |description_path|
      break if (raw_description = extract_element_content item, description_path)
    end
    description = Sanitize.clean(raw_description).squish if raw_description

    if description.blank? and @has_media_ns
      media_description = extract_element_content(item, @feed_elements[:media_description])
      description = Sanitize.clean(media_description).squish if media_description
    end
    description
  end

  def extract_properties(item)
    media_content_node = extract_node(item, @feed_elements[:media_content]).first
    return unless media_content_node
    properties = {}

    media_content_url = extract_node_attribute(media_content_node, :url)
    if media_content_url.present?
      media_content_props = { url: media_content_url }
      media_content_type = extract_node_attribute(media_content_node, :type)
      media_content_type ||= UrlParser.mime_type(media_content_url)
      media_content_props[:type] = media_content_type if media_content_type
      properties[:media_content] = media_content_props

      media_thumbnail_url = extract_element_content(media_content_node, @feed_elements[:media_thumbnail_url])
      media_thumbnail_url ||= extract_element_content(item, @feed_elements[:media_thumbnail_url])
      properties[:media_thumbnail] = { url: media_thumbnail_url } if media_thumbnail_url
    end

    properties
  end

  def extract_elements(item, *elements)
    Hash[elements.map { |element| [element, extract_element_content(item, @feed_elements[element])] }]
  end

  def extract_element_content(item, path)
    node = extract_node(item, path)
    node.present? && (content = node.map(&:inner_text).join(', ').squish).present? ? content : nil
  end

  def extract_node(item, path)
    return unless path
    namespace_hash = path_namespace_hash path
    namespace_hash ? item.xpath(path, namespace_hash) : item.xpath(path)
  end

  def path_namespace_hash(path)
    path_namespace = path.match(%r{[a-z]+:}i).to_s.gsub(/:/, '')
    path_namespace_url = NAMESPACE_URL_HASH[path_namespace.to_sym]
    { path_namespace => path_namespace_url } if path_namespace_url
  end

  def extract_node_attribute(node, attribute)
    attr_value = node.attr(attribute)
    attr_value.squish if attr_value.present?
  end
end
