module YoutubeVideosParser
  include YoutubeDocumentFetcher
  include RssFeedParser

  MAX_VIDEOS_PER_FEED = 500.freeze
  MAX_RESULTS_PER_FEED = 50.freeze
  FEED_ELEMENTS = { item: 'item',
                    published_at: %w(yt:recorded pubDate),
                    link: 'link',
                    title: 'title',
                    guid: 'guid',
                    description: 'description',
                    state: './/yt:state[@name=restricted][@reasonCode=private]',
                    duration: './/yt:duration/@seconds' }.freeze

  YT_NAMESPACE_URL = 'http://gdata.youtube.com/schemas/2007'.freeze
  YT_NAMESPACE_HASH = { yt: YT_NAMESPACE_URL }.freeze

  def each_item
    url = document_url
    while url do
      doc = fetch_document url
      @has_yt_namespace = doc.namespaces.values.include? YT_NAMESPACE_URL

      doc.xpath("//#{FEED_ELEMENTS[:item]}").each do |item|
        attributes = parse_item item
        yield attributes if attributes.present?
      end
      url = next_document_url doc
    end
  end

  protected

  def document_url(start_index = 1)
  end

  def next_document_url(document)
    next_start_index = extract_next_start_index document
    document_url(next_start_index) if next_start_index
  end

  def parse_item(item)
    return unless video_playable? item

    duration = extract_duration item
    return unless duration

    parsed_item = { duration: duration }
    parsed_item[:link] = item.xpath(FEED_ELEMENTS[:link]).inner_text
    parsed_item[:guid] = item.xpath(FEED_ELEMENTS[:guid]).inner_text
    parsed_item[:title] = item.xpath(FEED_ELEMENTS[:title]).inner_text
    raw_description = item.xpath(FEED_ELEMENTS[:description]).inner_text
    parsed_item[:description] = Nokogiri::HTML(raw_description).inner_text.squish
    parsed_item[:published_at] = extract_published_at FEED_ELEMENTS[:published_at], item

    parsed_item
  end

  def video_playable?(item)
    return true unless @has_yt_namespace
    item.xpath(FEED_ELEMENTS[:state], YT_NAMESPACE_HASH).blank?
  end

  def extract_duration(item)
    duration_in_seconds_str = item.xpath(FEED_ELEMENTS[:duration], YT_NAMESPACE_HASH).inner_text
    duration = ChronicDuration.output(duration_in_seconds_str.to_i, format: :chrono)
    duration = nil if duration == '0'
    duration
  end

  def extract_next_start_index(document)
    attrs = extract_document_attributes document
    next_start_index = attrs[:start_index] + attrs[:per_page]
    next_start_index if next_start_index <= [attrs[:total], MAX_VIDEOS_PER_FEED].min
  end

  def extract_document_attributes(document)
    total = document.xpath('/rss/channel/openSearch:totalResults').inner_text.to_i
    start_index = document.xpath('/rss/channel/openSearch:startIndex').inner_text.to_i
    per_page = document.xpath('/rss/channel/openSearch:itemsPerPage').inner_text.to_i
    { per_page: per_page, start_index:start_index, total: total }
  end
end
