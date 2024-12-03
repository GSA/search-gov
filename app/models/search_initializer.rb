module SearchInitializer
  include Api::V2::NonCommercialSearch

  attr_reader :aggregations, :collection, :matching_site_limits

  def initialize(options)
    super
    @options = options
    @query = (@query || '').squish
    @total = 0
    @limit = options[:limit]
    @offset = options[:offset]
    @next_offset_within_limit = options[:next_offset_within_limit]
    @highlight_options = options.slice(:pre_tags, :post_tags)
    @highlight_options[:highlighting] = options[:enable_highlighting]
    @enable_highlighting = options[:enable_highlighting] != false
    @include_facets = options[:include_facets] == 'true'
    @collection = options[:document_collection]
    @site_limits = options[:site_limits]
    @matching_site_limits = formatted_query_instance.matching_site_limits
  end

  def formatted_query
    formatted_query_instance.query
  end

  def formatted_query_instance
    @formatted_query_instance ||= I14yFormattedQuery.new(@query, domains_scope_options)
  end

  def as_json_result_hash(result)
    @include_facets ? super.merge(add_facets_to_results(result)) : super
  end
end
