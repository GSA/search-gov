module ContinuousWorker
  MAX_RETRIES = 3.freeze
  EXECUTE_INTERVAL = 15.minutes.freeze
  RETRY_INTERVAL = 5.minutes.freeze

  def self.start
    while true do
      execute_with_retry { yield }
      sleep(EXECUTE_INTERVAL)
    end
  end

  def self.execute_with_retry
    num_attempts = 0
    begin
      num_attempts += 1
      yield
    rescue => error
      if num_attempts <= MAX_RETRIES
        sleep(RETRY_INTERVAL)
        retry
      else
        raise error
      end
    end
  end
end
