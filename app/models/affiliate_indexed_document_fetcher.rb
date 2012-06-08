class AffiliateIndexedDocumentFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(affiliate_id, start_id, end_id, extent)
    extent_clause = case
      when extent == 'not_ok'
        "last_crawl_status <> 'OK' or isnull(last_crawl_status)"
      when extent == 'ok'
        "last_crawl_status = 'OK'"
      when extent == 'unfetched'
        "isnull(last_crawl_status)"
      else
        '1=1'
    end
    conditions = ["#{extent_clause} and id between ? and ?", start_id, end_id]
    Affiliate.find(affiliate_id).indexed_documents.select(:id).where(conditions).each do |indexed_document|
      IndexedDocument.find(indexed_document.id).fetch
    end
  end
end