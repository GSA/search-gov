class BingSearch < SearchEngine
  API_ENDPOINT = '/json.aspx'
  API_HOST= 'http://api.bing.net'
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  VALID_ADULT_FILTERS = %w{off moderate strict}

  attr_reader :sources

  self.api_endpoint = API_ENDPOINT

  def initialize(options = {})
    super(options) do |search_engine|
      search_engine.api_connection= connection_instance
      filter_index = get_filter_index(options[:filter])
      search_engine.filter_level= VALID_ADULT_FILTERS[filter_index]
    end
    @sources = index_sources
  end

  protected

  def params
    params_hash = {
      AppId: APP_ID,
      fdtrace: 1,
      Adult: filter_level,
      sources: sources,
      query: query
    }
    params_hash.merge!('Options' => 'EnableHighlighting') if enable_highlighting
    params_hash.merge!(ADDITIONAL_BING_PARAMS)
    params_hash
  end

  def parse_search_engine_response(response)
    bing_response = response.body.search_response
    SearchEngineResponse.new do |search_response|
      search_response.total = hits(bing_response)
      search_response.start_record = bing_offset(bing_response) + 1
      search_response.results = process_results(bing_response)
      search_response.end_record = search_response.start_record + search_response.results.size - 1
      spelling = bing_response.spell.results.first.value rescue nil
      search_response.spelling_suggestion = spelling_results(spelling)
      search_response.tracking_information = response.headers['X-FDT-Ref']
    end
  end

  private
  def connection_instance
    @@api_connection ||= CachedSearchApiConnection.new('bing_api', API_HOST, BING_CACHE_DURATION)
  end
end
