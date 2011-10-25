class SuperfreshUrlToIndexedDocument
  @queue = :usasearch

  def self.perform(url, affiliate_id)
    return unless SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate_id)
    IndexedDocument.fetch(url, affiliate_id)
  end
end