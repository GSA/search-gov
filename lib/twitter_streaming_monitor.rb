# frozen_string_literal: true

class TwitterStreamingMonitor
  POLLING_INTERVAL = 60

  @monitor = nil

  attr_reader :twitter_ids, :logger
  attr_accessor :tweet_consumer, :monitor_thread, :exit_flag

  def initialize(twitter_ids)
    @twitter_ids = twitter_ids
    @exit_flag = false
    @tweet_consumer = nil
    @monitor_thread = nil
    @logger = Logger.new('log/twitter.log')
  end

  class << self
    attr_accessor :monitor
  end

  def run
    logger.info "[#{Time.now.utc}] [TWITTER] [MONITOR] run"
    TwitterStreamingMonitor.monitor = self
    self.monitor_thread = Thread.new do
      Rails.application.executor.wrap { monitor_thread_body }
    end
  end

  def stop
    self.exit_flag = true
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads { monitor_thread&.join(2 * POLLING_INTERVAL) }
    self.monitor_thread = nil
    disconnect
  end

  def alive?
    monitor_thread&.alive?
  end

  private

  def monitor_thread_body
    logger.info "[#{Time.now.utc}] [TWITTER] [MONITOR] start monitor thread"
    loop do
      logger.info "[#{Time.now.utc}] [TWITTER] [MONITOR] twitter_ids: #{twitter_ids.get_object.inspect}"

      disconnect_if_necessary
      break if exit_flag

      connect_if_necessary
      sleep(POLLING_INTERVAL)
    end
  ensure
    ActiveRecord::Base.clear_active_connections!
  end

  def connect_if_necessary
    connect(twitter_ids.get_object_and_reset_changed) if need_to_connect?
  end

  def disconnect_if_necessary
    disconnect if need_to_disconnect?
  end

  def need_to_disconnect?
    twitter_ids.object_changed? || exit_flag || !tweet_consumer&.alive?
  end

  def disconnect
    tweet_consumer&.stop
    logger.info "[#{Time.now.utc}] [TWITTER] [DISCONNECT]"
    self.tweet_consumer = nil
  end

  def need_to_connect?
    !tweet_consumer&.alive? && !twitter_ids.get_object.empty? && !exit_flag
  end

  def connect(twitter_ids)
    logger.info "[#{Time.now.utc}] [TWITTER] [CONNECTING]"
    self.tweet_consumer = TwitterStreamConsumer.new(twitter_ids)
    tweet_consumer.follow
    sleep(0) until tweet_consumer&.alive?
    logger.info "[#{Time.now.utc}] [TWITTER] [CONNECTED]"
  end
end
