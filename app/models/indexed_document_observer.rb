class IndexedDocumentObserver < ActiveRecord::Observer
  def after_create(indexed_document)
    Resque.enqueue(IndexedDocumentFetcher, indexed_document.id)
    SuperfreshUrl.create(:url => indexed_document.url, :affiliate => indexed_document.affiliate)
  end
end