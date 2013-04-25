# coding: utf-8
class GoogleSearch < SearchEngine
  API_ENDPOINT = '/customsearch/v1'
  API_HOST = 'https://www.googleapis.com'
  API_KEY = 'AIzaSyAqgqnBqdXKtLfmEEzarf96hlnzD5koi34'
  SEARCH_CX = '015426204394000049396:9fkj8sbnfpi'
  VALID_ADULT_FILTERS = %w{off medium high}
  DEFAULT_LANGUAGE = 'lang_en'

  def initialize(options = {})
    super(options) do |search_engine|
      search_engine.api_connection= connection_instance
      search_engine.api_endpoint= API_ENDPOINT
      filter_index = get_filter_index(options[:filter])
      search_engine.filter_level= VALID_ADULT_FILTERS[filter_index]
    end
    @quota_user = options[:quota_user]
  end

  protected

  def params
    params_hash = {
      alt: :json,
      key: API_KEY,
      cx: SEARCH_CX,
      safe: filter_level,
      q: query,
      lr: language
    }
    params_hash.merge!(start: offset) unless offset == DEFAULT_OFFSET
    params_hash.merge!(quotaUser: @quota_user) if @quota_user.present?
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
    end
  end

  private

  def language
    I18n.locale == :es ? 'lang_es' : DEFAULT_LANGUAGE
  end

  def connection_instance
    @@api_connection ||= SearchApiConnection.new('google_api', API_HOST)
  end
end