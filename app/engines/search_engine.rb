class SearchEngine
  class SearchError < RuntimeError;
  end

  DEFAULT_OFFSET = 0
  DEFAULT_PER_PAGE = 10
  MAX_ATTEMPT_COUNT = 2

  class_attribute :api_endpoint, instance_writer: false

  attr_accessor :query,
                :offset,
                :per_page,
                :filter_level,
                :api_connection,
                :enable_highlighting

  def initialize(options = {})
    @query = options[:query]
    @per_page = options[:per_page] || DEFAULT_PER_PAGE
    @offset = options[:offset] || DEFAULT_OFFSET
    @enable_highlighting = options[:enable_highlighting].nil? || options[:enable_highlighting]
    yield self if block_given?
  end

  def execute_query
    http_params = params
    Rails.logger.debug "#{self.class.name} Url: #{api_endpoint}\nParams: #{http_params}"
    retry_block(attempts: MAX_ATTEMPT_COUNT, catch: [Faraday::TimeoutError, Faraday::ConnectionFailed]) do |attempt|
      start = Time.now.to_f
      cached_response = api_connection.get(api_endpoint, http_params)
      process_cached_response(cached_response, start, attempt)
    end
  rescue Exception => error
    raise SearchError.new(error)
  end

  protected

  def process_cached_response(cached_response, start, attempt)
    elapsed_seconds = Time.now.to_f - start

    response = parse_search_engine_response(cached_response.response)
    response.diagnostics = {
      result_count: response.results.size,
      from_cache: cached_response.cache_namespace,
      retry_count: attempt - 1,
      elapsed_time_ms: (elapsed_seconds * 1000).to_i,
    }

    response
  end

  def get_filter_index(filter_param_str)
    idx= (filter_param_str.present? && filter_param_str.to_s.match(/\d/)) ? filter_param_str.to_i : 1
    (0..2).include?(idx) ? idx : 1
  end

  def spelling_results(suggestion)
    return nil if suggestion.blank?
    spelling_suggestion = SpellingSuggestion.new(query, suggestion)
    spelling_suggestion.cleaned
  end
end
