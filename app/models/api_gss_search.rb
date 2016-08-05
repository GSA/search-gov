class ApiGssSearch < ApiCommercialSearch
  include Api::V2::AsJsonAppendWebSpellingCorrection
  self.default_module_tag = 'GWEB'.freeze

  protected

  def instantiate_engine(options)
    formatted_query_instance = GoogleFormattedQuery.new(@query,
                                                        domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:enable_highlighting,
                                   :next_offset_within_limit,
                                   :offset)
    engine_options.merge!(google_cx: options[:cx],
                          google_key: options[:api_key],
                          language: "lang_#{@affiliate.locale}",
                          per_page: options[:limit],
                          query: @formatted_query)
    ApiGssWebEngine.new engine_options
  end

  def handle_response(response)
    assign_spelling_suggestion_if_eligible(response.spelling_suggestion) if super
  end
end