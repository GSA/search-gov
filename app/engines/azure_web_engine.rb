class AzureWebEngine < AzureEngine
  API_ENDPOINT = '/Bing/SearchWeb/v1/Web'.freeze
  self.api_endpoint = API_ENDPOINT

  def initialize(options)
    super
    @next_offset_within_limit = options[:next_offset_within_limit]
  end

  def parse_search_engine_response(response)
    hashie_body = response.body
    AzureEngineResponse.new(self, hashie_body) do |search_response|
      search_response.results = process_results(hashie_body.d.results)
      search_response.next_offset = process_next_offset(hashie_body)
    end
  end

  protected

  def process_results(azure_results)
    azure_results.collect { |result| process_result result }.compact
  end

  def process_result(result)
    if result.title.present? &&
      result.description.present? &&
      result.url.present?
      mashify result
    end
  end

  def mashify(result)
    Hashie::Mash.new({
      description: result.description,
      title: result.title,
      url: result.url,
      display_url: StringProcessor.strip_highlights(result.display_url),
    })
  end

  def process_next_offset(hashie_body)
    if @next_offset_within_limit &&
      hashie_body.d.results.present? &&
      hashie_body.d._next.present?
      @azure_params.offset + @azure_params.limit
    end
  end
end

