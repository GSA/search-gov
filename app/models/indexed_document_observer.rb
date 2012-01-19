class IndexedDocumentObserver < ActiveRecord::Observer
  def after_create(indexed_document)
    Resque.enqueue(IndexedDocumentFetcher, indexed_document.id)
    SuperfreshUrl.create(:url => indexed_document.url, :affiliate => indexed_document.affiliate)
  end

  def after_destroy(indexed_document)
    indexed_domains = indexed_document.indexed_domain
    indexed_domains.delete if indexed_domains and indexed_domains.indexed_documents.empty?
  end
end