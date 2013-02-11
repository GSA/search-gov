class RssFeedData
  RSS_ELEMENTS = { item: 'item',
                   pubDate: %w(pubDate),
                   link: %w(link),
                   title: 'title',
                   guid: 'guid',
                   contributor: 'dc:contributor',
                   publisher: 'dc:publisher',
                   subject: 'dc:subject',
                   description: 'description' }.freeze

  ATOM_ELEMENTS = { item: 'xmlns:entry',
                    pubDate: %w(xmlns:published xmlns:updated),
                    link: %w(xmlns:link[@rel='alternate'][@href]/@href xmlns:link/@href),
                    title: 'xmlns:title',
                    guid: 'xmlns:id',
                    description: 'xmlns:content' }.freeze

  FEED_ELEMENTS = { rss: RSS_ELEMENTS, atom: ATOM_ELEMENTS }.freeze

  def initialize(rss_feed, ignore_older_items = true)
    @rss_feed = rss_feed
    @ignore_older_items = ignore_older_items
  end

  def import
    @rss_feed.rss_feed_urls.each do |rss_feed_url|
      begin
        RssFeedUrl.transaction do
          rss_feed_url.touch(:last_crawled_at)
          doc = Nokogiri::XML(Kernel.open(rss_feed_url.url))
          feed_type = detect_feed_type(doc)
          if feed_type.nil?
            rss_feed_url.update_attributes!(last_crawl_status: 'Unknown feed type.')
            next
          end

          feed_elements = FEED_ELEMENTS[feed_type]
          most_recently = rss_feed_url.news_items.present? ? rss_feed_url.news_items.first.published_at : nil
          extract_news_items(rss_feed_url, doc, feed_elements, most_recently)
          rss_feed_url.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS)
        end
      rescue Exception => e
        rss_feed_url.update_attributes!(last_crawl_status: e.message)
        Rails.logger.warn(e)
      end
    end
  end

  def detect_feed_type(document)
    case document.root.name
    when 'feed' then :atom
    when 'rss' then :rss
    else nil
    end
  end

  private

  def extract_news_items(rss_feed_url, doc, feed_elements, most_recently)
    return unless doc
    doc.xpath("//#{feed_elements[:item]}").each do |item|
      published_at = nil
      feed_elements[:pubDate].each do |pub_date_path|
        published_at_str = item.xpath(pub_date_path).inner_text
        next if published_at_str.blank?
        published_at = DateTime.parse published_at_str
        break if published_at.present?
      end

      break if most_recently and published_at < most_recently and @ignore_older_items

      link = ''
      feed_elements[:link].each do |link_path|
        link = item.xpath(link_path).inner_text
        break if link.present?
      end

      contributor = item.xpath(feed_elements[:contributor]).inner_text rescue nil
      subject = item.xpath(feed_elements[:subject]).inner_text rescue nil
      publisher = item.xpath(feed_elements[:publisher]).inner_text rescue nil

      title = item.xpath(feed_elements[:title]).inner_text
      guid = item.xpath(feed_elements[:guid]).inner_text
      guid = link if guid.blank?
      raw_description = item.xpath(feed_elements[:description]).inner_text
      description = Nokogiri::HTML(raw_description).inner_text.squish

      @rss_feed.news_items.where('guid = ? OR link = ?', guid, link).
          first_or_create!(rss_feed_url: rss_feed_url,
                           link: link,
                           title: title,
                           description: description,
                           published_at: published_at,
                           contributor: contributor,
                           publisher: publisher,
                           subject: subject,
                           guid: guid)
    end
  end
end