class IndexedDocumentValidator
  @queue = :high

  def self.perform(indexed_document_id)
    return unless (indexed_document = IndexedDocument.find_by_id(indexed_document_id))
    indexed_document.delete unless indexed_document.valid?
  end
end