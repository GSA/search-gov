class ApiRateLimiter
  DEFAULT_LIMIT = 500
  DEFAULT_TTL = 8.days.to_i

  cattr_reader :redis
  @@redis = Redis.new(host: REDIS_HOST,
                      port: REDIS_PORT,
                      db: 1)

  def initialize(namespace, soft_limit = false)
    @namespace = namespace
    @soft_limit = soft_limit
  end

  def within_limit(&block)
    limit = get_limit
    key = current_used_count_key
    used_count = get_or_initialize_used_count key

    if used_count < limit
      run key, &block
    else
      Rails.logger.warn "#{@namespace} limit reached: #{limit}"
      run key, &block if @soft_limit
    end
  end

  def get_or_initialize_used_count(key = nil)
    key ||= current_used_count_key
    used_count = @@redis.get(key)
    used_count ? used_count.to_i : initialize_used_count(key)
  end

  def get_limit
    outbound_limit ? outbound_limit.limit : DEFAULT_LIMIT
  end

  def current_used_count_key
    d = outbound_limit ? outbound_limit.current_interval : Date.current.to_fs(:db)
    "#{@namespace}:#{d}:used_count"
  end

  private

  def initialize_used_count(key)
    ttl = outbound_limit ? outbound_limit.ttl : DEFAULT_TTL
    @@redis.setnx key, 0
    @@redis.expire key, ttl
    @@redis.get(key).to_i
  end


  def increment(key)
    @@redis.incr key
  end

  def outbound_limit
    @outbound_limit ||= OutboundRateLimit.find_by_name @namespace
  end

  def run(key, &block)
    increment key
    yield
  end
end
