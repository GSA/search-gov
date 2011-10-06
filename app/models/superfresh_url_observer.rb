class SuperfreshUrlObserver < ActiveRecord::Observer
  @queue = :usasearch

  def after_save(superfresh_url)
    Resque.enqueue(SuperfreshUrlToIndexedDocument, superfresh_url.url, superfresh_url.affiliate_id)
  end
end
