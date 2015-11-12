class AzureCompositeEngine < AzureEngine
  API_ENDPOINT = '/Bing/Search/v1/Composite'.freeze
  NAMESPACE = 'azure_composite_api'.freeze

  self.api_endpoint = API_ENDPOINT
  self.api_namespace = NAMESPACE
  self.azure_parameters_class = AzureCompositeParameters

  def parse_search_engine_response(response)
    hashie_response = response.body
    AzureEngineResponse.new(self, hashie_response) do |search_response|
      process_composite_result hashie_response.d.results.first,
                               search_response
    end
  end

  protected

  def process_composite_result(composite_result, search_response)
    search_response.total = composite_result.image_total.to_i + composite_result.web_total.to_i
    search_response.results = composite_result.image + composite_result.web
    search_response.spelling_suggestion = process_spelling_suggestion(composite_result.spelling_suggestions)
    search_response.next_offset = next_offset(composite_result)
  end

  def process_spelling_suggestion(spelling_suggestions)
    spelling_suggestions.first.value if spelling_suggestions.present?
  end

  def next_offset(composite_result)
    total = composite_result.image_total.to_i + composite_result.web_total.to_i
    offset = composite_result.image_offset.to_i + composite_result.web_offset.to_i
    limit = composite_result.image.length + composite_result.web.length
    next_offset = offset + limit

    next_offset >= total ? nil : next_offset
  end
end

