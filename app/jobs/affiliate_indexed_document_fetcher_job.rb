# frozen_string_literal: true

class AffiliateIndexedDocumentFetcherJob < ApplicationJob
  queue_as :searchgov

  def perform(affiliate_id, start_id, end_id, scope)
    conditions = ['id between ? and ?', start_id, end_id]
    Affiliate.find(affiliate_id).indexed_documents.select(:id).send(scope.to_sym).
      where(conditions).order(:last_crawled_at).each do |indexed_document|
      IndexedDocument.find(indexed_document.id).fetch
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "Cannot find IndexedDocument to fetch:", e
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "Ignoring race condition in AffiliateIndexedDocumentFetcherJob:", e
  end
end
