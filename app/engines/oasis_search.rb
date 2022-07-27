class OasisSearch < SearchEngine
  API_ENDPOINT = '/api/v1/image.json'
  CACHE_DURATION_IN_SECONDS = 0

  self.api_endpoint = API_ENDPOINT

  def initialize(options = {})
    super(options) do |search_engine|
      search_engine.api_connection = connection_instance
    end
    @options = options
  end

  protected

  def params
    params_hash = { query: query, from: offset, size: per_page }
    params_hash.merge!(flickr_groups: @options[:flickr_groups].join(',')) if @options[:flickr_groups].present?
    params_hash.merge!(flickr_users: @options[:flickr_users].join(',')) if @options[:flickr_users].present?
    params_hash.merge!(mrss_names: @options[:mrss_names].join(',')) if @options[:mrss_names].present?
    params_hash
  end

  def parse_search_engine_response(response)
    oasis_response = response.body
    SearchEngineResponse.new do |search_response|
      search_response.start_record = oasis_response.offset + 1
      search_response.results = oasis_response.results
      search_response.end_record = search_response.start_record + search_response.results.size - 1
      search_response.total = oasis_response.total
      spelling = oasis_response.suggestion.text rescue nil
      search_response.spelling_suggestion = spelling_results(spelling)
    end
  end

  private

  def connection_instance
    @@api_connection ||= CachedSearchApiConnection.new('oasis_api', Oasis.host, CACHE_DURATION_IN_SECONDS)
  end
end
