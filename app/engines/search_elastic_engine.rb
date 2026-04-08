class SearchElasticEngine < I14ySearch
  def search
    params = process_array_parameters(build_search_params).merge(indices: ENV.fetch('SEARCHELASTIC_INDEX'))
    search_results = SearchElastic::DocumentSearch.new(params, affiliate: @affiliate).search
    build_response(search_results)
  end

  def log_serp_impressions
    modules << 'SRCH' if @total.positive?
  end

  private

  def process_array_parameters(params)
    array_parameter_keys.each do |key|
      params[key] = extract_array(params[key]) if params[key].present?
    end

    params
  end

  def extract_array(value)
    value.split(',').map(&:strip).map(&:downcase)
  end

  def array_parameter_keys
    SearchElastic::DocumentQuery::FILTERABLE_TEXT_FIELDS + %i[include ignore_tags]
  end

  def build_response(search_results)
    Hashie::Mash::Rash.new({
      developer_message: 'OK',
      metadata: build_metadata(search_results),
      results: search_results.results,
      status: 200
    })
  end

  def build_metadata(search_results)
    {
      aggregations: search_results.aggregations,
      offset: search_results.offset,
      suggestion: search_results.suggestion,
      total: search_results.total
    }
  end
end
