class BingSearch < SearchEngine
  API_HOST = 'https://api.cognitive.microsoft.com'.freeze
  VALID_ADULT_FILTERS = %w{off moderate strict}
  CACHE_LIFETIME = BING_CACHE_DURATION

  attr_reader :options

  class_attribute :api_endpoint
  class_attribute :api_cache_namespace
  class_attribute :response_parser_class

  def initialize(options = { })
    super
    @options = options
    @api_connection = self.class.api_connection
    Rails.logger.error("CACHE_LIFETIME: #{CACHE_LIFETIME}")
  end

  def execute_query
    api_connection.connection.headers['Ocp-Apim-Subscription-Key'] = subscription_key if subscription_key
    super
  end

  def params
    {
      offset: offset,
      count: count,
      mkt: market,
      q: options[:query],
      safeSearch: safe_search,
      responseFilter: 'WebPages',
      textDecorations: !!options[:enable_highlighting],
    }.merge(ADDITIONAL_BING_PARAMS)
  end

  protected

  def self.api_host
    API_HOST
  end

  def parse_search_engine_response(bing_response)
    parser = response_parser_class.new(self, bing_response)
    parser.parsed_response
  end

  def market
    Language.bing_market_for_code(language)
  end

  def language
    options[:language]
  end

  def offset
    options[:offset] || 0
  end

  def count
    options[:limit] || 20
  end

  def safe_search
    filter_index = get_filter_index(options[:filter])
    VALID_ADULT_FILTERS[filter_index]
  end

  def subscription_key
    options[:password] || hosted_subscription_key
  end

  def hosted_subscription_key
    nil
  end

  class << self
    def api_connection
      @api_connection ||= { }
      @api_connection[self] ||= CachedSearchApiConnection.new(api_cache_namespace, api_host, CACHE_LIFETIME)
    end
  end
end
