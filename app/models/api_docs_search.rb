class ApiDocsSearch < ApiCommercialSearch
  self.default_module_tag = 'AWEB'.freeze

  attr_reader :document_collection

  def initialize(options = {})
    @document_collection = options[:document_collection] || (DocumentCollection.find(options[:dc]) rescue nil)
    super(options)
  end


  def as_json(_options = {})
    {
      docs: {
        next_offset: @next_offset,
        results: as_json_results_to_hash,
      }
    }
  end

  def as_json_result_hash(result)
    {
      title: result.title,
      url: result.url,
      snippet: result.description,
    }
  end

  protected

  def instantiate_engine(options)
    formatted_query_instance = AzureFormattedQuery.new(@query, domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:enable_highlighting,
                                   :limit,
                                   :next_offset_within_limit,
                                   :offset)
    engine_options.merge!(language: @affiliate.locale,
                          password: options[:api_key],
                          query: @formatted_query)
    AzureWebEngine.new engine_options
  end

  def domains_scope_options
    included_domains = @document_collection.present? ? @document_collection.url_prefixes.collect { |url_prefix| url_prefix.prefix.gsub(%r[(^https?://|/$)], '') } : @affiliate.site_domains.pluck(:domain)
    {included_domains: included_domains,
     excluded_domains: @affiliate.excluded_domains.pluck(:domain)}
  end
end

