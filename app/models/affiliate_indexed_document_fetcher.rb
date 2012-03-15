class AffiliateIndexedDocumentFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(affiliate_id, start_id, end_id, extent)
    extent_clause = '1=1'
    if extent == "not_ok"
      extent_clause = "last_crawl_status <> 'OK' or isnull(last_crawl_status)"
    elsif extent == "ok"
      extent_clause = "last_crawl_status = 'OK'"
    elsif extent == "unfetched"
      extent_clause = "isnull(last_crawl_status)"
    end
    conditions = ["#{extent_clause} and id between ? and ?", start_id, end_id]
    Affiliate.find(affiliate_id).indexed_documents.find_each(:batch_size => 100, :conditions => conditions) do |indexed_document|
      indexed_document.fetch
    end
  end
end