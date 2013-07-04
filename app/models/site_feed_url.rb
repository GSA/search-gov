class SiteFeedUrl < ActiveRecord::Base
  belongs_to :affiliate
  before_validation NormalizeUrl.new(:rss_url)
  validates_presence_of :rss_url
  after_destroy :fast_destroy_indexed_rss_docs

  def self.refresh_all
    select(:id).each do |site_feed_url|
      Resque.enqueue_with_priority(:low, SiteFeedUrlFetcher, site_feed_url.id)
    end
  end

  def fetch
    touch(:last_checked_at)
    rss_doc = Nokogiri::XML(HttpConnection.get(rss_url))
    records = parse(rss_doc)
    links = records.map do |record|
      affiliate.indexed_documents.create(url: record[:link], title: record[:title], description: record[:description],
                                         last_crawl_status: IndexedDocument::SUMMARIZED_STATUS, source: 'rss')
      record[:link]
    end
    update_attributes!(last_fetch_status: 'OK')
    IndexedDocument.destroy_all(["affiliate_id = ? and url not in (?) and source = 'rss'", affiliate.id, links.compact.sort.uniq])
    affiliate.refresh_indexed_documents(IndexedDocument::SUMMARIZED_STATUS)
  rescue Exception => e
    Rails.logger.warn(e)
    update_attributes!(last_fetch_status: e.message)
  end

  private

  def parse(doc)
    items = doc.xpath("//item")
    cnt = [quota, items.size].min
    items.first(cnt).map do |item|
      link = item.xpath('link').inner_text.squish
      title = item.xpath('title').inner_text.squish
      raw_description = item.xpath('description').inner_text
      description = Nokogiri::HTML(raw_description).inner_text.squish
      {link: link, title: title, description: description}
    end
  end

  def fast_destroy_indexed_rss_docs
    Sunspot.remove(IndexedDocument) do
      with(:affiliate_id, self.affiliate.id)
      without(:source, 'rss')
    end
    IndexedDocument.select(:id).where(affiliate_id: self.affiliate.id, source: 'rss').delete_all
  end
end
