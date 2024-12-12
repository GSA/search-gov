module SearchInitializer
  include Api::V2::NonCommercialSearch

  attr_reader :aggregations, :collection, :matching_site_limits

  def initialize(options)
    super
    setup_instance_variables(options)
    setup_highlighting_options(options)
    setup_search_parameters(options)
  end

  private

  def setup_instance_variables(options)
    @options = options
    @query = (@query || '').squish
    @total = 0
    @collection = options[:document_collection]
    @site_limits = options[:site_limits]
  end

  def setup_highlighting_options(options)
    @highlight_options = options.slice(:pre_tags, :post_tags)
    @highlight_options[:highlighting] = options[:enable_highlighting]
    @enable_highlighting = options[:enable_highlighting] != false
  end

  def setup_search_parameters(options)
    @limit = options[:limit]
    @offset = options[:offset]
    @next_offset_within_limit = options[:next_offset_within_limit]
    @include_facets = options[:include_facets].is_a?(String) ? options[:include_facets] == 'true' : options[:include_facets]
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
