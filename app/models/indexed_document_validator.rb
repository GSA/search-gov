class IndexedDocumentValidator
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(indexed_document_id)
    return unless (indexed_document = IndexedDocument.find_by_id(indexed_document_id))
    indexed_document.destroy unless indexed_document.valid?
  end
end
