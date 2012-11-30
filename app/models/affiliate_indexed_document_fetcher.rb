class AffiliateIndexedDocumentFetcher
  extend Resque::Plugins::Priority
  @queue = :primary
  MAX_RUNTIME_IN_MINUTES = 60

  def self.perform(affiliate_id, start_id, end_id, scope)
    max_runtime_in_minutes = ENV['MAX_RUNTIME_IN_MINUTES'] || MAX_RUNTIME_IN_MINUTES
    start_time = Time.now
    conditions = ["id between ? and ?", start_id, end_id]
    Affiliate.find(affiliate_id).indexed_documents.select(:id).send(scope.to_sym).where(conditions).order(:last_crawled_at).each do |indexed_document|
      return if ((Time.now-start_time)/60).to_i > max_runtime_in_minutes.to_i
      IndexedDocument.find(indexed_document.id).fetch
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "Ignoring race condition in AffiliateIndexedDocumentFetcher: #{e}"
  end
end