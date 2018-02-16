require 'datadog/statsd'

class CaptchaMetrics
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def increment_counter_for(activity)
    statsd.increment(activity, tags: tags)
  end

  private

  def statsd
    @statsd ||= Datadog::Statsd.new('127.0.0.1', 8125, { namespace: 'dgsearch_captcha' })
  end

  def tags
    bot_or_not_headers = request.headers.map { |k, _v| k if k.start_with?('HTTP_X_BON_') }.compact
    bot_or_not_headers.sort.map { |h| "#{h.sub('HTTP_X_BON_', '')}:#{request.headers[h]}" }
  end
end
