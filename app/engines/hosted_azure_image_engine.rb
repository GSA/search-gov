# TODO: inherit from AzureCompositeEngine
class HostedAzureImageEngine < AzureEngine
  API_ENDPOINT = '/Bing/Search/v1/Composite'.freeze
  IMAGE_FILTERS = 'Aspect:Square'.freeze
  SOURCES = 'image+spell'.freeze

  self.api_endpoint = API_ENDPOINT
  self.api_namespace = AzureCompositeEngine::NAMESPACE
  self.azure_parameters_class = AzureCompositeParameters

  def initialize(options)
    super options.merge! image_filters: IMAGE_FILTERS,
                         limit: options[:per_page],
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
    Hashie::Mash::Rash.new({
      title: result.title,
      url: result.source_url,
      media_url: result.media_url,
      display_url: result.display_url,
      content_type: result.content_type,
      file_size: result.file_size.to_i,
      width: result.width.to_i,
      height: result.height.to_i,
      thumbnail: {
        url: result.thumbnail.media_url,
        content_type: result.thumbnail.content_type,
        file_size: result.thumbnail.file_size.to_i,
        width: result.thumbnail.width.to_i,
        height: result.thumbnail.height.to_i,
      },
    })
  end

  def process_spelling_suggestion(spelling_suggestions)
    spelling_suggestions.first.value if spelling_suggestions.present?
  end
end

