class ApiAzureCompositeSearch < ApiCommercialSearch
  def handle_response(response)
    return unless response
    @results = response.results
    @total = response.total
    @next_offset = response.next_offset
    @spelling_suggestion = response.spelling_suggestion
  end

  protected

  def instantiate_engine(options)
    formatted_query_instance = AzureFormattedQuery.new(@query, domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:enable_highlighting,
                                   :limit,
                                   :offset,
                                   :image_filters,
                                   :sources)
    engine_options.merge!(language: @affiliate.locale,
                          password: options[:api_key],
                          query: @formatted_query)
    AzureCompositeEngine.new engine_options
  end
end
