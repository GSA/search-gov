class IndexedDocumentFetcher
  @queue = :usasearch

  def self.perform(indexed_document_id)
    indexed_document = IndexedDocument.find(indexed_document_id)
    return unless indexed_document
    indexed_document.fetch
  end
end