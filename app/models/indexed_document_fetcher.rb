class IndexedDocumentFetcher
  @queue = :medium

  def self.perform(indexed_document_id)
    return unless (indexed_document = IndexedDocument.find_by_id(indexed_document_id))
    indexed_document.fetch
  end
end