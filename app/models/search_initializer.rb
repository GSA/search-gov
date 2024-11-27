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

  def result_url(result)
    result.link if result.respond_to?(:link)
  end

  def as_json_result_hash(result)
    @include_facets ? super.merge(add_facets_to_results(result)) : super
  end

  def add_facets_to_results(result)
    I14ySearch::FACET_FIELDS.reject { |f| f == 'created' || result[f].nil? }.each_with_object({}) do |field, fields|
      field_key = field.to_sym == :changed ? :updated_date : field.to_sym
      field_value = field.to_sym == :changed ? result['changed'].to_date : result[field]
      fields[field_key] = field_value
    end
  end
end
