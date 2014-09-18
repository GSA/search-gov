# coding: utf-8
class GoogleSearch < SearchEngine
  API_ENDPOINT = '/customsearch/v1'
  API_HOST = 'https://www.googleapis.com'
  API_KEY = 'AIzaSyBCGurjhAbQlF1rlJmxCa5Re8rCAlZjtiQ'
  SEARCH_CX = '005675969675701682971:tsue0ko9g0k'
  VALID_ADULT_FILTERS = %w{off medium high}
  DEFAULT_LANGUAGE = 'lang_en'
  CACHE_DURATION = 5 * 60
  DEFAULT_START = 1.freeze

  attr_reader :start

  def initialize(options = {})
    super(options) do |search_engine|
      search_engine.api_connection= connection_instance
      search_engine.api_endpoint= API_ENDPOINT
      filter_index = get_filter_index(options[:filter])
      search_engine.filter_level= VALID_ADULT_FILTERS[filter_index]
    end
    @start = @offset + 1
    @google_cx = options[:google_cx] || SEARCH_CX
    @google_key = options[:google_key] || API_KEY
  end

  protected

  def params
    params_hash = {
      alt: :json,
      key: @google_key,
      cx: @google_cx,
      safe: filter_level,
      q: query,
      lr: language,
      quotaUser: 'USASearch'
    }
    params_hash.merge!(start: @start) unless @start == DEFAULT_START
    params_hash
  end

  def parse_search_engine_response(response)
    google_response = response.body
    SearchEngineResponse.new do |search_response|
      search_response.start_record = google_response.queries.request.first.start_index.to_i
      search_response.results = process_results(google_response)
      search_response.end_record = search_response.start_record + search_response.results.size - 1
      search_response.total = google_response.queries.request.first.total_results.to_i
      spelling = google_response.spelling.corrected_query rescue nil
      search_response.spelling_suggestion = spelling_results(spelling)
      search_response.tracking_information = response.headers['etag']
    end
  end

  private

  def language
    I18n.locale == :es ? 'lang_es' : DEFAULT_LANGUAGE
  end

  def connection_instance
    @@api_connection ||= SearchApiConnection.new('google_api', API_HOST, CACHE_DURATION)
  end
end