class RateLimitedSearchApiConnection < CachedSearchApiConnection
  def initialize(namespace, site, cache_duration = 60 * 60 * 6)
    super
    @rate_limiter = ApiRateLimiter.new namespace
  end

  def get(api_endpoint, param_hash)
    response = @cache.read api_endpoint, param_hash
    return response if response

    @rate_limiter.within_limit do
      response = @connection.get api_endpoint, param_hash
      cache_response api_endpoint, param_hash, response
    end
    response
  end
end
