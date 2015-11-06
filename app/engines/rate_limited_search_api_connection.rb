class RateLimitedSearchApiConnection < CachedSearchApiConnection
  def initialize(namespace, site, cache_duration = 60 * 60 * 6, soft_limit = false)
    super(namespace, site, cache_duration)
    @rate_limiter = ApiRateLimiter.new namespace, soft_limit
  end

  private

  def get_from_api(api_endpoint, param_hash)
    @rate_limiter.within_limit { super }
  end
end
