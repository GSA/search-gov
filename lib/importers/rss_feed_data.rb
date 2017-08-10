class RssFeedData
  include RssFeedParser

  NAMESPACE_URL_HASH = {
    content: 'http://purl.org/rss/1.0/modules/content/',
    dc: 'http://purl.org/dc/elements/1.1/',
    media: 'http://search.yahoo.com/mrss/'
  }.freeze

  attr_reader :rss_feed_url, :document
  delegate :url, :current_url, :news_items, to: :rss_feed_url
  delegate :feed_type, :xml, :elements, to: :document

  def initialize(rss_feed_url, ignore_older_items = true)
    @rss_feed_url = rss_feed_url
    @ignore_older_items = ignore_older_items
  end

  def import
    rss_feed_url.touch(:last_crawled_at)
    @document = rss_feed_url.document

    if rss_feed_url.redirected?
      return unless validate_redirection
    end

    return unless validate_document
    return unless validate_rss_items

    detect_namespaces
    validation_errors = extract_news_items
    last_crawl_status = generate_last_crawl_status(validation_errors)
    rss_feed_url.update_attributes!(last_crawl_status: last_crawl_status)
  rescue => e
    Rails.logger.warn(e)
    rss_feed_url.update_attributes!(last_crawl_status: e.message)
  end

  private

  def validate_document
    if !(document && document.valid?)
      rss_feed_url.update_attributes!(last_crawl_status: 'Unknown feed type.')
      false
    else
      true
    end
  end

  def validate_redirection
    if rss_feed_url.protocol_redirect?
      rss_feed_url.update_attributes(url: current_url)
    else
      rss_feed_url.update_attributes!(last_crawl_status: "redirection forbidden: #{url} -> #{current_url}")
      false
    end
  end

  def validate_rss_items
    if rss_items.blank?
      rss_feed_url.update_attributes!(last_crawl_status: "Feed looks empty")
      false
    else
      true
    end
  end

  def generate_last_crawl_status(validation_errors)
    validation_errors.empty? ? RssFeedUrl::OK_STATUS : most_common_validation_error(validation_errors)
  end

  def most_common_validation_error(validation_errors)
    validation_errors.group_by { |i| i }.max { |x, y| x[1].length <=> y[1].length }[0]
  end

  def detect_namespaces
    @has_content_ns = xml.namespaces.values.include?(NAMESPACE_URL_HASH[:content])
    @has_dc_ns = xml.namespaces.values.include?(NAMESPACE_URL_HASH[:dc])
    @has_media_ns = xml.namespaces.values.include?(NAMESPACE_URL_HASH[:media])
  end

  def extract_news_items
    return unless rss_items

    most_recently = news_items.present? ? news_items.first.published_at : nil
    validation_errors = []
    rss_items.each do |item|
      published_at = extract_published_at item, *elements[:pubDate]
      if published_at.blank?
        validation_errors << "Missing pubDate field"
        next
      end
      break if found_an_older_item_to_ignore?(most_recently, published_at)

      link = extract_link(item)
      if link.blank?
        validation_errors << "Missing link field"
        next
      end

      attributes = build_attributes(item, link, published_at)

      news_item = news_items.where(guid: attributes[:guid]).first ||
        news_items.where(link: link).first_or_initialize

      if link_status_code_404?(link)
        validation_errors << "Linked URL does not exist (HTTP 404)"
        news_item.destroy unless news_item.new_record?
        next
      end

      next if unchanged_existing_news_item?(news_item, published_at)

      news_item.assign_attributes attributes
      unless news_item.save
        validation_errors << news_item.errors.full_messages.first
        Rails.logger.error "news_item: #{news_item.errors.full_messages}"
      end
    end
    validation_errors
  end

  def rss_items
    document.items
  end

  def build_attributes(item, link, published_at)
    attributes = { link: link, published_at: published_at }.reverse_merge(extract_other_attributes(item))
    attributes[:guid] = link if attributes[:guid].blank?
    attributes
  end

  def unchanged_existing_news_item?(news_item, published_at)
    !news_item.new_record? && news_item.published_at >= published_at
  end

  def found_an_older_item_to_ignore?(most_recently, published_at)
    most_recently and published_at < most_recently and @ignore_older_items
  end

  def extract_link(item)
    link = nil
    elements[:link].each do |link_path|
      break if (link = extract_element_content item, link_path)
    end
    link.squish if link
  end

  def extract_other_attributes(item)
    attributes = extract_elements(item, :guid, :title)
    attributes.merge!(extract_elements(item, :contributor, :publisher, :subject)) if @has_dc_ns
    attributes[:description] = extract_description(item)
    attributes[:body] = extract_body(item)
    attributes[:properties] = extract_properties(item) if @has_media_ns
    attributes
  end

  def link_status_code_404?(link)
    status = UrlStatusCodeFetcher.fetch(link)[link]
    DocumentFetchLogger.new(link, 'exists_check', { status: status }).log
    status =~ /404/
  end

  def extract_body(item)
    body = nil
    raw_body = extract_element_content item, elements[:body]
    body = Sanitize.clean(raw_body) if raw_body

    if body.blank? and @has_media_ns
      media_body = extract_element(item, :media_text)
      body = Sanitize.clean(media_body) if media_body
    end
    body
  end

  def extract_description(item)
    raw_description = nil
    elements[:description].each do |description_path|
      break if (raw_description = extract_element_content item, description_path)
    end
    description = Sanitize.clean(raw_description) if raw_description

    if description.blank? and @has_media_ns
      media_description = extract_element(item, :media_description)
      description = Sanitize.clean(media_description) if media_description
    end
    description
  end

  def extract_properties(item)
    media_content_node = extract_node(item, elements[:media_content]).first
    return unless media_content_node
    properties = {}

    media_content_url = extract_node_attribute(media_content_node, :url)
    if media_content_url.present?
      media_content_props = { url: media_content_url }
      media_content_type = extract_node_attribute(media_content_node, :type)
      media_content_type ||= UrlParser.mime_type(media_content_url)
      media_content_props[:type] = media_content_type if media_content_type
      properties[:media_content] = media_content_props

      media_thumbnail_url = extract_element(media_content_node, :media_thumbnail_url)
      media_thumbnail_url ||= extract_element(item, :media_thumbnail_url)
      properties[:media_thumbnail] = { url: media_thumbnail_url } if media_thumbnail_url
    end

    properties
  end

  def extract_elements(item, *elements)
    Hash[elements.map { |element| [element, extract_element(item, element)] }]
  end

  def extract_element(parent, element)
    path = elements[element]
    extract_element_content parent, path
  end

  def extract_element_content(parent, path)
    node = extract_node(parent, path)
    node.present? && (content = node.map(&:inner_text).join(', ').squish).present? ? content : nil
  end

  def extract_node(parent, path)
    return unless path
    namespace_hash = path_namespace_hash path
    namespace_hash ? parent.xpath(path, namespace_hash) : parent.xpath(path)
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
