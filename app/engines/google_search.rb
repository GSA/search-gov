# coding: utf-8
class GoogleSearch < SearchEngine
  API_ENDPOINT = '/customsearch/v1'
  API_HOST = 'https://www.googleapis.com'
  API_KEY = '***REMOVED***'
  SEARCH_CX = '005675969675701682971:usi2bmqvnp8'
  VALID_ADULT_FILTERS = %w{off medium high}
  DEFAULT_START = 1
  PER_PAGE_RANGE = (1..10).freeze
  NAMESPACE = 'google_api'.freeze
  BING_TO_GOOGLE_LOCALE_MAPPING = {
    he: 'iw',
    zh: 'zh-cn'
  }

  attr_reader :start

  class_attribute :search_engine_response_class, instance_writer: false

  self.api_endpoint = API_ENDPOINT
  self.search_engine_response_class = SearchEngineResponse

  def initialize(options = {})
    super(options) do |search_engine|
      search_engine.api_connection = connection_instance(options[:google_key], options[:google_cx])
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
      cx: @google_cx,
      key: @google_key,
      quotaUser: 'USASearch',
      q: query,
      safe: filter_level
    }
    params_hash.merge!(lr: language) if Language.exists?(code: I18n.locale, is_google_supported: true)
    params_hash.merge!(start: @start) unless @start == DEFAULT_START
    params_hash.merge!(num: @per_page) if per_page_is_valid_and_not_default_value?
    params_hash
  end

  def parse_search_engine_response(response)
    google_response = response.body
    search_engine_response_class.new do |search_response|
      extract_google_response google_response, search_response
      search_response.tracking_information = response.headers['etag']
      yield google_response, search_response if block_given?
    end
  end

  def language
    "lang_#{BING_TO_GOOGLE_LOCALE_MAPPING.fetch(I18n.locale, I18n.locale)}"
  end

  def extract_google_response(google_response, search_response)
    search_response.start_record = google_response.queries.request.first.start_index.to_i
    search_response.results = process_results(google_response)
    search_response.end_record = search_response.start_record + search_response.results.size - 1
    search_response.total = google_response.queries.request.first.total_results.to_i
    spelling = google_response.spelling.corrected_query rescue nil
    search_response.spelling_suggestion = spelling_results(spelling)
  end

  private

  def connection_instance(google_key, google_cx)
    google_key.blank? && google_cx.blank? ? rate_limited_api_connection : unlimited_api_connection
  end

  def unlimited_api_connection
    @@unlimited_api_connection = CachedSearchApiConnection.new(NAMESPACE, API_HOST, GOOGLE_CACHE_DURATION)
  end

  def rate_limited_api_connection
    @@rate_limited_api_connection = RateLimitedSearchApiConnection.new(NAMESPACE, API_HOST, GOOGLE_CACHE_DURATION)
  end

  def per_page_is_valid_and_not_default_value?
    PER_PAGE_RANGE.include?(@per_page) && @per_page != DEFAULT_PER_PAGE
  end
end
