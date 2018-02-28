class BingV6Search < BingV5Engine
  API_HOST= 'https://www.bingapis.com'
  API_CACHE_NAMESPACE = 'bing_v6'.freeze
  APP_ID = Rails.application.secrets.bing_v6['app_id'].freeze
  VALID_ADULT_FILTERS = %w{off moderate strict}

  attr_reader :options

  self.api_host = API_HOST
  self.api_cache_namespace = API_CACHE_NAMESPACE

  def initialize(options = {})
    super
    @options = options
    @api_connection = connection_instance
  end

  def params
    super.merge({
      AppId: APP_ID,
      safeSearch: safe_search,
    }).merge(ADDITIONAL_BING_PARAMS)
  end

  protected

  def password
    APP_ID
  end

  def safe_search
    filter_index = get_filter_index(options[:filter])
    VALID_ADULT_FILTERS[filter_index]
  end

  def connection_instance
    @@api_connection ||= CachedSearchApiConnection.new(api_cache_namespace, API_HOST, BING_CACHE_DURATION)
  end
end
