# frozen_string_literal: true

class IndexedDocumentFetcherJob < ApplicationJob
  queue_as :searchgov

  def perform(indexed_document_id:)
    return unless (indexed_document = IndexedDocument.find_by(id: indexed_document_id))

    indexed_document.fetch
  end
end
