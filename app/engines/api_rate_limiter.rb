class ApiRateLimiter
  DEFAULT_LIMIT = 500
  KEY_TTL = 8.days.to_i

  cattr_reader :redis
  @@redis = Redis.new(host: REDIS_HOST,
                      port: REDIS_PORT,
                      db: 1)

  def initialize(namespace)
    @namespace = namespace
  end

  def within_limit(&block)
    limit = get_limit
    key = current_used_count_key
    used_count = get_or_initialize_used_count key

    if used_count < limit
      increment key
      yield
    else
      Rails.logger.warn "#{@namespace} limit reached: #{limit}"
    end
  end

  def get_or_initialize_used_count(key = nil)
    key ||= current_used_count_key
    used_count = @@redis.get(key)
    used_count ? used_count.to_i : initialize_used_count(key)
  end

  def get_limit
    outbound_limit = OutboundRateLimit.find_by_name @namespace
    outbound_limit ? outbound_limit.limit : DEFAULT_LIMIT
  end

  private

  def initialize_used_count(key)
    @@redis.setnx key, 0
    @@redis.expire key, KEY_TTL
    @@redis.get(key).to_i
  end

  def current_used_count_key
    "#{@namespace}:#{Date.current.to_s(:db)}:used_count"
  end

  def increment(key)
    @@redis.incr key
  end
end
