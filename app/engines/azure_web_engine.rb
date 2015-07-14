class AzureWebEngine < SearchEngine
  API_ENDPOINT = '/Bing/SearchWeb/v1/Web'.freeze
  API_HOST = 'https://api.datamarket.azure.com'.freeze

  def initialize(options)
    super
    self.api_connection = connection_instance
    self.api_endpoint = API_ENDPOINT
    @next_offset_within_limit = options[:next_offset_within_limit]
    @password = options[:password]
    @params = AzureParameters.new options
  end

  def params
    @params.to_hash
  end

  def execute_query
    api_connection.basic_auth nil, @password
    super
  end

  def parse_search_engine_response(response)
    azure_response = response.body
    CommercialSearchEngineResponse.new do |search_response|
      if azure_response.d && azure_response.d.results
        search_response.results = process_results(azure_response.d.results)
        search_response.next_offset = process_next_offset(azure_response)
        yield search_response if block_given?
      end
    end
  end

  protected

  def process_results(azure_results)
    azure_results.collect do |result|
      process_result result
    end.compact
  end

  def process_result(result)
    if result.title.present? &&
      result.description.present? &&
      result.url.present?
      mashify result
    end
  end

  def mashify(result)
      Hashie::Mash.new(description: result.description,
                       title: result.title,
                       url: result.url)
  end

  def process_next_offset(azure_response)
    if @next_offset_within_limit &&
      azure_response.d.results.present? &&
      azure_response.d._next.present?
      @params.offset + @params.limit
    end
  end

  private

  def connection_instance
    @@api_connection ||= BasicAuthSearchApiConnection.new('azure_api', API_HOST)
  end
end

