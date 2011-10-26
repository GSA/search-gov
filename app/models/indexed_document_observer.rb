class IndexedDocumentObserver < ActiveRecord::Observer
  @queue = :usasearch

  def after_create(indexed_document)
    Resque.enqueue(IndexedDocumentFetcher, indexed_document.id)
  end
end