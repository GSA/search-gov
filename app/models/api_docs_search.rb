module ApiDocsSearch
  attr_reader :document_collection

  def initialize(options = {})
    @document_collection = options[:document_collection] || (DocumentCollection.find(options[:dc]) rescue nil)
    super(options)
  end

  def as_json(_options = {})
    {
      engine: self.default_module_tag,
      docs: {
        next_offset: @next_offset,
        results: as_json_results_to_hash,
      }
    }
  end

  def domains_scope_options
    included_domains = @document_collection.present? ? @document_collection.url_prefixes.collect { |url_prefix| url_prefix.prefix.gsub(%r[(^https?://|/$)], '') } : @affiliate.site_domains.pluck(:domain)
    {included_domains: included_domains,
     excluded_domains: @affiliate.excluded_domains.pluck(:domain)}
  end
end