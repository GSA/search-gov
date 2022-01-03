class SiteFeedUrlData
  include RssFeedParser

  DEFAULT_ATTRIBUTES = { last_crawl_status: IndexedDocument::SUMMARIZED_STATUS }.freeze

  def initialize(site_feed_url)
    @site_feed_url = site_feed_url
    @site = @site_feed_url.affiliate
    @document_ids = Set.new
  end

  def import
    @site_feed_url.touch(:last_checked_at)
    fetch_new_or_updated_rss_items
    @site_feed_url.update!(last_fetch_status: 'OK')
    delete_obsolete_documents
    @site.refresh_indexed_documents IndexedDocument::SUMMARIZED_STATUS
  rescue Exception => e
    Rails.logger.warn(e)
    @site_feed_url.update!(last_fetch_status: e.message)
  end

  private

  def fetch_new_or_updated_rss_items
    items_attributes.each do |attrs|
      doc = @site.indexed_documents.where(url: attrs[:url]).first_or_initialize
      next unless doc.source == 'rss'

      if doc.new_record? || updating_doc?(doc.published_at, attrs[:published_at])
        assign_attributes doc, attrs
        doc.save
      end
      @document_ids << doc.id if doc.id
    end
  end

  def items_attributes
    rss_doc = Nokogiri::XML HttpConnection.get @site_feed_url.rss_url
    parse rss_doc
  end

  def parse(doc)
    items = doc.xpath('//item')
    cnt = [@site_feed_url.quota, items.size].min
    items.first(cnt).map do |item|
      url = item.xpath('link').inner_text.squish
      title = item.xpath('title').inner_text.squish
      raw_description = item.xpath('description').inner_text
      description = Nokogiri::HTML(raw_description).inner_text.squish
      published_at = extract_published_at item, 'pubDate'
      { url: url, title: title, description: description, published_at: published_at }
    end
  end

  def updating_doc?(old_published_at, new_published_at)
    if new_published_at && old_published_at
      new_published_at > old_published_at
    elsif new_published_at
      true
    end
  end

  def assign_attributes(doc, attributes)
    doc.assign_attributes attributes.merge(DEFAULT_ATTRIBUTES)
  end

  def delete_obsolete_documents
    existing_ids = IndexedDocument.where("affiliate_id = ? AND source = 'rss'", @site.id).pluck(:id)
    obsolete_ids = existing_ids - @document_ids.to_a
    IndexedDocument.fast_delete obsolete_ids
  end
end
