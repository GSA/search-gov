class ApiAzureSearch < ApiCommercialSearch
  self.default_module_tag = 'AWEB'.freeze

  protected

  def instantiate_engine(options)
    formatted_query_instance = AzureFormattedQuery.new(@query, domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:enable_highlighting,
                                   :limit,
                                   :next_offset_within_limit,
                                   :offset)
    engine_options.merge!(language: @affiliate.locale,
                          password: options[:api_key],
                          query: @formatted_query)
    AzureWebEngine.new engine_options
  end
end
