class SiteSearch < WebSearch
  attr_reader :document_collection

  def initialize(options = {})
    @document_collection = options[:document_collection] || (DocumentCollection.find(options[:dc]) rescue nil)
    options[:affiliate].search_engine='Google' if @document_collection and @document_collection.depth >= DocumentCollection::DEPTH_WHEN_BING_FAILS
    super(options)
  end

  protected

  def sitelink_generator_names
    @document_collection.sitelink_generator_names
  end

  def domains_scope_options
    included_domains = @document_collection.present? ?
      @document_collection.url_prefixes.collect { |url_prefix| url_prefix.prefix.gsub(%r[(^https?://|/$)], '') } : @affiliate.site_domains.pluck(:domain)
    {included_domains: included_domains,
     excluded_domains: @affiliate.excluded_domains.pluck(:domain)}
  end

  def populate_additional_results
  end
end
