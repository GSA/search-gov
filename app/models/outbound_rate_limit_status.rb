class OutboundRateLimitStatus
  attr_reader :used_count, :used_percentage

  def self.find_by_name(name)
    rate_limit = OutboundRateLimit.find_by_name name
    return unless rate_limit

    OutboundRateLimitStatus.new(rate_limit)
  end

  def initialize(outbound_rate_limit)
    @outbound_rate_limit = outbound_rate_limit
    rate_limiter = ApiRateLimiter.new(@outbound_rate_limit.name)
    @used_count = rate_limiter.get_or_initialize_used_count
    @used_percentage = get_used_percentage
  end

  def to_s
    ["name:#{@outbound_rate_limit.name}",
     "limit:#{@outbound_rate_limit.limit}",
     "used_count:#{@used_count}",
     "used_percentage:#{@used_percentage}"].join(';')
  end

  private

  def get_used_percentage
    "#{((@used_count.to_f * 100) / @outbound_rate_limit.limit).round}%"
  end
end
