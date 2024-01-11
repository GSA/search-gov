# frozen_string_literal: true

require 'datadog/statsd'

module ResqueJobStats
  # NB: this method name needs to come before "around_perform_with_timeout"
  # alphabetically so that this hook gets called before resque-timeout's
  # hook which allows the rescue below to catch the Timeout::Error thrown
  # by resque-timeout
  def around_perform_with_stats(*args)
    Rails.logger.info("performing job #{name} with arguments #{args.inspect}")

    statsd.increment('run_count')
    statsd.time('run_duration') do
      begin
        yield
      rescue
        statsd.increment('failure_count')
        raise
      end
    end
  end

  def statsd
    @statsd ||= begin
      statsd = Datadog::Statsd.new
      statsd.namespace = 'dgsearch.resque_jobs'
      statsd.tags = ["job:#{name}"]
      statsd
    end
  end
end
