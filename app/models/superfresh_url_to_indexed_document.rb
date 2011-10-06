class SuperfreshUrlToIndexedDocument
  @queue = :usasearch

  def self.perform(url, affiliate_id)
    return unless SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate_id)
    document = IndexedDocument.crawl(url)
    if document and document.is_a?(IndexedDocument)
      document.affiliate_id = affiliate_id
      document.save!
    end      
  end
end