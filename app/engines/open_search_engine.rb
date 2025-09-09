class OpenSearchEngine < SearchElasticEngine
  def search
    params = process_array_parameters(build_search_params).merge(indices: ENV.fetch('OPENSEARCH_INDEX'))
    search_results = OpenSearch::DocumentSearch.new(params, affiliate: @affiliate).search
    build_response(search_results)
  end
end
