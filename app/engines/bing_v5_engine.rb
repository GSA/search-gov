class BingV5Engine < SearchEngine
  API_HOST = 'https://api.cognitive.microsoft.com'.freeze
  API_CACHE_NAMESPACE = 'bing_v5_api'.freeze
  CACHE_LIFETIME = AZURE_CACHE_DURATION
  DEFAULT_HOSTED_PASSWORD = Rails.application.secrets.hosted_azure['v5_account_key'].freeze

  class_attribute :api_host
  class_attribute :api_endpoint
  class_attribute :api_cache_namespace
  class_attribute :default_hosted_password
  class_attribute :response_parser_class

  attr_reader :options

  self.api_host = API_HOST
  self.api_cache_namespace = API_CACHE_NAMESPACE
  self.default_hosted_password = DEFAULT_HOSTED_PASSWORD

  def initialize(options)
    super
    @options = options
    @api_connection = is_hosted_search? ? self.class.rate_limited_api_connection : self.class.unlimited_api_connection
  end

  def execute_query
    api_connection.connection.headers['Ocp-Apim-Subscription-Key'] = password
    super
  end

  def params
    {
      offset: offset,
      count: count,
      mkt: market,
      q: options[:query],
      safeSearch: 'Moderate',
    }
  end

  protected

  def parse_search_engine_response(bing_response)
    parser = response_parser_class.new(self, bing_response)
    parser.parsed_response
  end

  def is_hosted_search?
    !options.include?(:password)
  end

  def password
    is_hosted_search? ? default_hosted_password : options[:password]
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

  class << self
    def unlimited_api_connection
      @bing_v5_unlimited_api_connection ||= { }
      @bing_v5_unlimited_api_connection[self] ||= CachedSearchApiConnection.new(api_cache_namespace, api_host, CACHE_LIFETIME)
    end

    def rate_limited_api_connection
      @bing_v5_rate_limited_api_connection ||= { }
      @bing_v5_rate_limited_api_connection[self] ||= RateLimitedSearchApiConnection.new(api_cache_namespace, api_host, CACHE_LIFETIME, true)
    end
  end
end
