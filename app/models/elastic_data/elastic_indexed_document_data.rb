# frozen_string_literal: true

class ElasticIndexedDocumentData
  DAYS_BACK = 7

  attr_reader :language, :indexed_document

  def initialize(indexed_document)
    @indexed_document = indexed_document
    @language = indexed_document.affiliate.indexing_locale
  end

  def to_builder
    return if indexed_document.last_crawl_status_error?

    Jbuilder.new do |json|
      json.(indexed_document, :id, :affiliate_id, :url)
      json.language language
      %w[title description body].each do |field|
        json.set! "#{field}.#{language}", indexed_document.send(field)
      end
      json.popularity LinkPopularity.popularity_for(indexed_document.url, DAYS_BACK)
      json.published_at indexed_document.published_at&.strftime('%Y-%m-%dT%H:%M:%S')
    end
  end
end
