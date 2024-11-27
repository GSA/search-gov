module SearchInitializer
  include Api::V2::NonCommercialSearch

  I14Y_SUCCESS = 200

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

  def handle_response(response)
    return unless response && response.status == I14Y_SUCCESS

    process_valid_response(response)
  end

  def process_valid_response(response)
    @total = response.metadata.total
    @next_offset = @offset + @limit if @next_offset_within_limit && @total > (@offset + @limit)
    post_processor = I14yPostProcessor.new(@enable_highlighting, response.results, @affiliate.excluded_urls_set)
    post_processor.post_process_results
    process_pagination_values(post_processor, response)
    process_metadata_values(response)
  end

  def process_pagination_values(post_processor, response)
    @results = paginate(response.results)
    @normalized_results = process_data_for_redesign(post_processor)
    @startrecord = ((@page - 1) * @per_page) + 1
    @endrecord = @startrecord + @results.size - 1
  end

  def process_metadata_values(response)
    @spelling_suggestion = response.metadata.suggestion.text if response.metadata.suggestion.present?
    @aggregations = response.metadata.aggregations if response.metadata.aggregations.present?
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
