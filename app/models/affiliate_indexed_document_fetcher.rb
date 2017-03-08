class AffiliateIndexedDocumentFetcher
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.before_perform_with_timeout(*_args)
    Resque::Plugins::Timeout.timeout = 1.hour
  end

  def self.perform(affiliate_id, start_id, end_id, scope)
    conditions = ["id between ? and ?", start_id, end_id]
    Affiliate.find(affiliate_id).indexed_documents.select(:id).send(scope.to_sym).where(conditions).order(:last_crawled_at).each do |indexed_document|
      IndexedDocument.find(indexed_document.id).fetch
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "Ignoring race condition in AffiliateIndexedDocumentFetcher: #{e}"
  end
end
