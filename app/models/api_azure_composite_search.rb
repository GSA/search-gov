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
    formatted_query_instance = BingFormattedQuery.new(@query, domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:enable_highlighting,
                                   :limit,
                                   :offset,
                                   :image_filters,
                                   :sources)
    engine_options.merge!(language: @affiliate.locale,
                          password: options[:api_key],
                          query: @formatted_query)
    search_engine_class.new(engine_options)
  end

  private

  def search_engine_class
    if is_api_key_bing_v5?
      is_image_search? ? BingV5ImageEngine : BingV5WebEngine
    else
      AzureCompositeEngine
    end
  end
end
