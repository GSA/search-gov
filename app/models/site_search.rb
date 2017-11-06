class SiteSearch < WebSearch
  attr_reader :document_collection

  def initialize(options = {})
    @document_collection = options[:document_collection] || (DocumentCollection.find(options[:dc]) rescue nil)
    options[:affiliate].search_engine='Google' if document_collection and document_collection.depth >= DocumentCollection::DEPTH_WHEN_BING_FAILS
    super(options)
  end

  protected

  def sitelink_generator_names
    document_collection.sitelink_generator_names if document_collection
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build(site: @affiliate,
                                    collection: document_collection)
  end

  def populate_additional_results
  end
end
