class HostedAzureImageEngine < AzureEngine
  API_ENDPOINT = '/Bing/Search/v1/Composite'.freeze
  AZURE_HOSTED_PASSWORD = YAML.load_file("#{Rails.root}/config/hosted_azure.yml")[Rails.env]['account_key'].freeze
  IMAGE_FILTERS = 'Aspect:Square'.freeze
  SOURCES = 'image+spell'.freeze

  self.api_endpoint = API_ENDPOINT
  self.azure_parameters_class = AzureCompositeParameters

  def initialize(options)
    super options.merge! image_filters: IMAGE_FILTERS,
                         limit: options[:per_page],
                         password: AZURE_HOSTED_PASSWORD,
                         sources: SOURCES
  end

  def parse_search_engine_response(response)
    hashie_response = response.body
    AzureEngineResponse.new(self, hashie_response) do |search_response|
      process_composite_result hashie_response.d.results.first,
                               search_response
    end
  end

  protected

  def connection_instance
    @@api_connection ||= BasicAuthSearchApiConnection.new('azure_composite_api', API_HOST)
  end

  def process_composite_result(composite_result, search_response)
    search_response.total = composite_result.image_total.to_i
    search_response.results = process_results composite_result.image
    search_response.spelling_suggestion = process_spelling_suggestion composite_result.spelling_suggestions
  end

  def process_results(azure_results)
    azure_results.collect { |result| process_result result }.compact
  end

  def process_result(result)
    if result.title.present? &&
      result.source_url.present? &&
      result.thumbnail &&
      result.thumbnail.media_url.present?
      mashify result
    end
  end

  def mashify(result)
    Hashie::Rash.new thumbnail: { url: result.thumbnail.media_url },
                     title: result.title,
                     url: result.source_url
  end

  def process_spelling_suggestion(spelling_suggestions)
    spelling_suggestions.first.value if spelling_suggestions.present?
  end
end

