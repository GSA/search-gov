#TODO: move to /engines dir?
class SearchEngine
  class SearchError < RuntimeError;
  end

  DEFAULT_OFFSET = 1
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50

  attr_accessor :query,
                :offset,
                :per_page,
                :filter_level,
                :api_connection,
                :api_endpoint,
                :enable_highlighting

  def initialize(options = {})
    @query = options[:query]
    #TODO: look at logic from Search class
    @offset = options[:offset] || DEFAULT_OFFSET
    @per_page = options[:per_page] || DEFAULT_PER_PAGE
    @enable_highlighting = options[:enable_highlighting].nil? || options[:enable_highlighting]
    yield self
  end

  def execute_query
    http_params = params
    Rails.logger.debug "#{self.class.name} Url: #{api_endpoint}\nParams: #{http_params}"
    response = api_connection.get(api_endpoint, http_params)
    parse_search_engine_response(response)
  rescue Exception => error
    raise SearchError.new(error)
  end

  protected

  def get_filter_index(filter_param_str)
    idx= (filter_param_str.present? && filter_param_str.to_s.match(/\d/)) ? filter_param_str.to_i : 1
    (0..2).include?(idx) ? idx : 1
  end

  def spelling_results(did_you_mean_suggestion)
    spelling_suggestion = SpellingSuggestion.new(query, did_you_mean_suggestion)
    spelling_suggestion.cleaned
  end

end