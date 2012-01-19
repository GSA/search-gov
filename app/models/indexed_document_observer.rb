class IndexedDocumentObserver < ActiveRecord::Observer
  def after_create(indexed_document)
    Resque.enqueue(IndexedDocumentFetcher, indexed_document.id)
    SuperfreshUrl.create(:url => indexed_document.url, :affiliate => indexed_document.affiliate)
  end

  def after_destroy(indexed_document)
    indexed_document.indexed_domain.delete if indexed_document.indexed_domain.indexed_documents.empty?
  end
end