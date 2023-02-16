class ApiWebSearch < ApiCommercialSearch
  def query_formatting_klass
  end

  def engine_klass
  end

  def instantiate_engine(options)
    formatted_query_instance = query_formatting_klass.new(@query, domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:enable_highlighting,
                                   :limit,
                                   :next_offset_within_limit,
                                   :offset)
    engine_options.merge!(language: @affiliate.locale,
                          password: options[:api_key],
                          query: @formatted_query)
    engine_klass.new(**engine_options)
  end
end