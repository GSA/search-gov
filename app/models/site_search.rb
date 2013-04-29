class SiteSearch < WebSearch
  attr_reader :document_collection

  def initialize(options = {})
    @document_collection = options[:document_collection] || (DocumentCollection.find(options[:dc]) rescue nil)
    options[:affiliate].search_engine='Google' if @document_collection and @document_collection.depth >= DocumentCollection::DEPTH_WHEN_BING_FAILS
    super(options)
  end

  protected

  def domains_scope_options
    included_domains = @document_collection.url_prefixes.collect { |url_prefix| url_prefix.prefix.gsub(%r[(^https?://|/$)], '') }
    {included_domains: included_domains,
     excluded_domains: @affiliate.excluded_domains_as_array,
     scope_ids: @affiliate.scope_ids_as_array}
  end

  def populate_additional_results
  end
end