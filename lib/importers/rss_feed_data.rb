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
                   media_content: 'media:content[@url]',
                   media_thumbnail: 'media:thumbnail[@url]' }.freeze

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

    feed_elements = FEED_ELEMENTS[feed_type]
    most_recently = @rss_feed_url.news_items.present? ? @rss_feed_url.news_items.first.published_at : nil
    extract_news_items(doc, feed_elements, most_recently)
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

  private

  def extract_news_items(doc, feed_elements, most_recently)
    return unless doc
    has_media_ns = doc.namespaces['xmlns:media'].present?
    doc.xpath("//#{feed_elements[:item]}").each do |item|
      published_at = nil
      feed_elements[:pubDate].each do |pub_date_path|
        published_at_str = item.xpath(pub_date_path).inner_text
        next if published_at_str.blank?
        published_at = DateTime.parse published_at_str
        break if published_at.present?
      end

      next unless published_at.present?
      break if most_recently and published_at < most_recently and @ignore_older_items

      link = ''
      feed_elements[:link].each do |link_path|
        link = item.xpath(link_path).inner_text
        break if link.present?
      end
      link.squish! if link.present?

      contributor = item.xpath(feed_elements[:contributor]).inner_text rescue nil
      subject = item.xpath(feed_elements[:subject]).inner_text rescue nil
      publisher = item.xpath(feed_elements[:publisher]).inner_text rescue nil

      title = item.xpath(feed_elements[:title]).inner_text
      guid = item.xpath(feed_elements[:guid]).inner_text
      guid = link if guid.blank?
      guid.squish! if guid.present?
      raw_description = item.xpath(feed_elements[:description]).inner_text
      description = Nokogiri::HTML(raw_description).inner_text.squish

      if description.blank? and has_media_ns
        media_description = item.xpath('./media:description').first
        if media_description
          description = Nokogiri::HTML(media_description.inner_text).inner_text.squish
        end
      end

      properties = {}
      if has_media_ns && feed_elements[:media_content].present? and
          (media_content = item.xpath(feed_elements[:media_content]).first)
        url = media_content.attr('url').to_s.squish
        if url.present?
          type = media_content.attr('type').to_s.squish
          type ||= determine_media_type_from_url url
          media_content_props = { url: url }
          media_content_props[:type] = type if type.present?
          properties[:media_content] = media_content_props

          if feed_elements[:media_thumbnail].present? and
              (media_thumbnail = item.xpath(feed_elements[:media_thumbnail]).first)
            url = media_thumbnail.attr('url').to_s.squish
            properties[:media_thumbnail] = { url: url } if url.present?
          end
        end
      end

      news_item = @rss_feed_url.news_items.where('guid = :guid OR link = :link', guid: guid, link: link).first_or_initialize
      news_item.assign_attributes(guid: guid,
                                  link: link,
                                  title: title,
                                  description: description,
                                  published_at: published_at,
                                  contributor: contributor,
                                  publisher: publisher,
                                  subject: subject,
                                  properties: properties)
      unless news_item.save
        Rails.logger.error "news_item: #{news_item.errors.full_messages}"
      end
    end
  end

  def self.determine_media_type_from_url(url)
    case url
    when /\.(gif)$/i then
      'image/gif'
    when /\.(jpg|jpeg|jpe|jif|jfif|jfi)$/i then
      'image/jpeg'
    when /\.(png)$/i then
      'image/png'
    end
  end
end
