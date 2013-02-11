module YoutubeVideosParser
  MAX_RESULTS_PER_FEED = 50.freeze
  FEED_ELEMENTS = { item: 'item',
                    pubDate: 'pubDate',
                    link: 'link',
                    title: 'title',
                    guid: 'guid',
                    description: 'description' }.freeze

  def feed_document(url)
    Nokogiri::XML(Kernel.open(url))
  end

  def parse_item(item)
    parsed_item = {}
    parsed_item[:link] = item.xpath(FEED_ELEMENTS[:link]).inner_text
    parsed_item[:guid] = item.xpath(FEED_ELEMENTS[:guid]).inner_text
    parsed_item[:title] = item.xpath(FEED_ELEMENTS[:title]).inner_text
    raw_description = item.xpath(FEED_ELEMENTS[:description]).inner_text
    parsed_item[:description] = Nokogiri::HTML(raw_description).inner_text.squish
    published_at_str = item.xpath(FEED_ELEMENTS[:pubDate]).inner_text
    parsed_item[:published_at] = DateTime.parse published_at_str
    parsed_item
  end
end