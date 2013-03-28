module TwitterApiRunner
  MAX_RETRY_ATTEMPTS = 3.freeze
  SLEEP_INTERVAL = 15.minutes.freeze
  RATE_LIMIT_BUFFER = 1.minute.freeze

  def self.run
    num_attempts = 0
    begin
      num_attempts += 1
      yield
    rescue Twitter::Error::ServiceUnavailable, Twitter::Error::TooManyRequests => error
      if num_attempts <= MAX_RETRY_ATTEMPTS
        sleep_duration = error.is_a?(Twitter::Error::TooManyRequests) ? (error.rate_limit.reset_in + RATE_LIMIT_BUFFER) : SLEEP_INTERVAL
        sleep(sleep_duration)
        retry
      else
        raise error
      end
    end
  end
end