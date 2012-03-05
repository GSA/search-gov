class AffiliateIndexedDocumentFetcher
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(affiliate_id, start_id, end_id)
    Affiliate.find(affiliate_id).indexed_documents.find_each(:batch_size => 100, :conditions => ["id between ? and ?", start_id, end_id]) do |indexed_document|
      indexed_document.fetch
    end
  end
end