module SearchInitializer
  include Api::V2::NonCommercialSearch

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
  end

  def as_json_result_hash(result)
    @include_facets ? super.merge(add_facets_to_results(result)) : super
  end
end
