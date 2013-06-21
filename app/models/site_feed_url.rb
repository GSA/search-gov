class SiteFeedUrl < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :rss_url
  after_destroy :fast_destroy_indexed_docs

  def fetch
    touch(:last_checked_at)
    rss_doc = Nokogiri::XML(HttpConnection.get(rss_url))
    records = parse(rss_doc)
    links = []
    records.each do |record|
      affiliate.indexed_documents.create(url: record[:link], title: record[:title], description: record[:description],
                                         last_crawl_status: IndexedDocument::SUMMARIZED_STATUS)
      links << record[:link]
    end
    update_attributes!(last_fetch_status: 'OK')
    IndexedDocument.destroy_all(["affiliate_id = ? and url not in (?)", affiliate.id, links.compact.sort.uniq])
    affiliate.refresh_indexed_documents(IndexedDocument::SUMMARIZED_STATUS)
  rescue Exception => e
    Rails.logger.warn(e)
    update_attributes!(last_fetch_status: e.message)
  end

  private

  def parse(doc)
    doc.xpath("//item").first(quota).map do |item|
      begin
        link = item.xpath('link').inner_text.squish
        title = item.xpath('title').inner_text.squish
        raw_description = item.xpath('description').inner_text
        description = Nokogiri::HTML(raw_description).inner_text.squish
        {link: link, title: title, description: description}
      rescue Exception
        nil
      end
    end.compact
  end

  def fast_destroy_indexed_docs
    Sunspot.remove(IndexedDocument) { with(:affiliate_id, self.affiliate.id) }
    IndexedDocument.select(:id).where(affiliate_id: self.affiliate.id).delete_all
  end
end
