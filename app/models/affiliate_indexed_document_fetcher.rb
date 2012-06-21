class AffiliateIndexedDocumentFetcher
  extend Resque::Plugins::Priority
  @queue = :primary
  MAX_RUNTIME_IN_MINUTES = 60

  def self.perform(affiliate_id, start_id, end_id, extent)
    start_time = Time.now
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
    Affiliate.find(affiliate_id).indexed_documents.select(:id).where(conditions).order(:last_crawled_at).each do |indexed_document|
      return if ((Time.now-start_time)/60).to_i > MAX_RUNTIME_IN_MINUTES
      IndexedDocument.find(indexed_document.id).fetch
    end
  end
end