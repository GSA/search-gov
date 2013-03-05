class BingSearch < SearchEngine
  API_ENDPOINT = '/json.aspx'
  API_HOST= 'http://api.bing.net'
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  VALID_ADULT_FILTERS = %w{off moderate strict}

  attr_reader :sources

  def initialize(options = {})
    super(options) do |search_engine|
      search_engine.api_connection= connection_instance
      search_engine.api_endpoint= API_ENDPOINT
      filter_index = get_filter_index(options[:filter])
      search_engine.filter_level= VALID_ADULT_FILTERS[filter_index]
    end
    @sources = index_sources
    @scope_ids = options[:scope_ids]
  end

  protected

  def params
    params_hash = {
      AppId: APP_ID,
      Adult: filter_level,
      sources: sources,
      query: query
    }
    params_hash.merge!('Options' => 'EnableHighlighting') if enable_highlighting
    params_hash.merge!('web.offset' => offset) unless offset== DEFAULT_OFFSET
    params_hash.merge!('web.count' => per_page) unless per_page == DEFAULT_PER_PAGE
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
    end
  end

  def process_results(response)
    web_results = response.web.results || []
    processed = web_results.collect do |result|
      title = result.title rescue nil
      content = result.description || ''
      title.present? ? Hashie::Rash.new({title: title, unescaped_url: result.url, content: content}) : nil
    end
    processed.compact
  end

  def hits(response)
    (response.web.results.blank? ? 0 : response.web.total) rescue 0
  end

  def bing_offset(response)
    (response.web.results.blank? ? 0 : response.web.offset) rescue 0
  end

  def index_sources
    'Spell Web'
  end

  #TODO: remove url_in_bing and normalize_url checks since I nuked the routine

  private
  def connection_instance
    @@api_connection ||= SearchApiConnection.new('bing_api', API_HOST)
  end
end
