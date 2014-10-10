class RateLimitedSearchApiConnection
  attr_reader :connection

  def initialize(namespace, site, cache_duration = 60 * 60 * 6)
    @connection = Faraday.new site do |conn|
      conn.request :json
      conn.response :rashify
      conn.response :json
      conn.headers[:user_agent] = 'USASearch'
      conn.adapter :net_http_persistent
    end
    @cache = ApiCache.new namespace, cache_duration
    @rate_limiter = ApiRateLimiter.new namespace
  end

  def get(api_endpoint, param_hash)
    response = @cache.read api_endpoint, param_hash
    return response if response

    response = nil
    @rate_limiter.within_limit do
      response = @connection.get api_endpoint, param_hash
      cache_response api_endpoint, param_hash, response
    end
    response || Hashie::Rash.new
  end

  private

  def cache_response(api_endpoint, param_hash, response)
    if response.status == 200
      @cache.write api_endpoint, param_hash, response
    end
  end
end
