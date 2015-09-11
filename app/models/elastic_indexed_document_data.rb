class ElasticIndexedDocumentData
  DAYS_BACK = 7

  def initialize(indexed_document)
    @indexed_document = indexed_document
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@indexed_document, :id, :affiliate_id, :title, :description, :body, :url)
      json.language "#{@indexed_document.affiliate.indexing_locale}_analyzer"
      json.popularity LinkPopularity.popularity_for(@indexed_document.url, DAYS_BACK)
      json.published_at @indexed_document.published_at.strftime("%Y-%m-%dT%H:%M:%S") if @indexed_document.published_at?
    end unless @indexed_document.last_crawl_status_error?
  end

end
