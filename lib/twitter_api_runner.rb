module TwitterApiRunner
  MAX_RETRY_ATTEMPTS = 3.freeze
  SLEEP_INTERVAL = 15.minutes.freeze
  RATE_LIMIT_BUFFER = 1.minute.freeze

  def self.run
    num_attempts = 0
    begin
      num_attempts += 1
      yield
    rescue Twitter::Error => error
      sleep_duration = extract_sleep_duration error
      if num_attempts <= MAX_RETRY_ATTEMPTS && sleep_duration > 0
        sleep sleep_duration
        retry
      else
        raise error
      end
    end
  end

  private

  def self.extract_sleep_duration(error)
    case
      when Twitter::Error::TooManyRequests === error
          error.rate_limit.reset_in + RATE_LIMIT_BUFFER
      when Twitter::Error::ServiceUnavailable === error
        SLEEP_INTERVAL
      when error.message.to_s.squish =~ /execution expired/i
        SLEEP_INTERVAL
      else
        0
    end
  end
end
