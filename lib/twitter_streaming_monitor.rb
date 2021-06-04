# frozen_string_literal: true

class TwitterStreamingMonitor
  POLLING_INTERVAL = 60

  @monitor = nil

  attr_reader :twitter_ids
  attr_accessor :tweet_consumer, :monitor_thread, :exit_flag

  def initialize(twitter_ids)
    @twitter_ids = twitter_ids
    @exit_flag = false
    @tweet_consumer = nil
    @monitor_thread = nil
  end

  class << self
    attr_accessor :monitor
  end

  def self.run
    return if monitor&.alive?

    twitter_ids = SynchronizedObjectHolder.new { TwitterProfile.active_twitter_ids }
    self.monitor = TwitterStreamingMonitor.new(twitter_ids)
    monitor.run
  end

  def self.stop
    monitor.stop
  end

  def run
    self.monitor_thread = Thread.new { monitor_thread_body }
    sleep(0) until monitor_thread.alive?
  end

  def stop
    self.exit_flag = true
    monitor_thread&.join(1)
    self.monitor_thread = nil
    disconnect
  end

  def alive?
    monitor_thread&.alive?
  end

  private

  def monitor_thread_body
    Rails.logger.info "[#{Time.now.utc}] [TWITTER] [MONITOR START]"

    loop do
      disconnect if need_to_disconnect?
      break if exit_flag

      connect(twitter_ids.get_object_and_reset_changed) if need_to_connect?
      sleep(POLLING_INTERVAL)
    end
  end

  def need_to_disconnect?
    twitter_ids.object_changed? || exit_flag || !tweet_consumer&.alive?
  end

  def disconnect
    tweet_consumer&.stop
    Rails.logger.info "[#{Time.now.utc}] [TWITTER] [DISCONNECT]"
    self.tweet_consumer = nil
  end

  def need_to_connect?
    !tweet_consumer&.alive? && !twitter_ids.get_object.empty? && !exit_flag
  end

  def connect(twitter_ids)
    self.tweet_consumer = TwitterStreamConsumer.new(twitter_ids)
    tweet_consumer.follow
    sleep(0) until tweet_consumer&.alive?
    Rails.logger.info "[#{Time.now.utc}] [TWITTER] [CONNECT]"
  end
end
