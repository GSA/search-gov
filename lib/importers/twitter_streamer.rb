# frozen_string_literal: true

class TwitterStreamer
  RECONNECT_WAIT_TIME = 120.seconds
  ACTIVE_TWITTER_IDS_POLLING_INTERVAL = 60.seconds

  attr_accessor :event_queue, :active_twitter_ids, :streaming_thread, :reconnect_time
  attr_reader :logger

  def initialize(logger)
    @logger = logger
    @event_queue = Queue.new
    @active_twitter_ids = []
    @reconnect_time = Time.now.utc
  end

  def stream_tweets
    self.active_twitter_ids = fetch_active_twitter_ids
    create_streaming_thread
    while might_get_more_events?
      dispatch(event_queue.pop) unless event_queue.empty?
      update_active_twitter_ids
    end
    destroy_streaming_thread
  end

  private

  def wait_until_time_to_reconnect
    now = Time.now.utc
    return if now >= reconnect_time

    logger.info "[#{Time.now.utc}] [TWITTER] [WAIT] Waiting #{reconnect_time - now}"
    sleep(reconnect_time - now)
  end

  def streaming_thread_body
    return if active_twitter_ids.empty?

    logger.info "[#{Time.now.utc}] [TWITTER] [CONNECT] Connecting to Twitter to follow #{active_twitter_ids.size} profiles: #{active_twitter_ids.inspect}."
    connect
  rescue StandardError => e
    event_queue.push(e)
  ensure
    logger.info "[#{Time.now.utc}] [TWITTER] [DISCONNECT]"
    self.reconnect_time = Time.now.utc + RECONNECT_WAIT_TIME
    client.close
  end

  def connect
    client.filter(follow: active_twitter_ids.join(',')) do |twitter_event|
      event_queue.push(twitter_event)
    end
  end

  def client
    @client ||= Twitter::Streaming::Client.new do |config|
      Rails.application.secrets.twitter.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end

  def create_streaming_thread
    wait_until_time_to_reconnect
    self.streaming_thread = Thread.new { streaming_thread_body }
  end

  def destroy_streaming_thread
    streaming_thread&.kill
    streaming_thread&.join
    self.streaming_thread = nil
  end

  def might_get_more_events?
    streaming_thread.alive? || !event_queue.empty?
  end

  def dispatch(event)
    case event
    when Twitter::Tweet
      on_tweet(event)
    when Twitter::Streaming::DeletedTweet
      on_delete_tweet(event)
    when StandardError
      on_error(event)
    end
  end

  def on_tweet(tweet)
    logger.info "[#{Time.now.utc}] [TWITTER] [STREAMING] New tweet received: @#{tweet.user.screen_name}: #{tweet.text}"
    return unless active_twitter_ids.include?(tweet.user.id)

    save_tweet(tweet)
  end

  def save_tweet(tweet)
    logger.info "[#{Time.now.utc}] [TWITTER] [STREAMING] storing: @#{tweet.user.screen_name}: #{tweet.text}"
    TwitterData.import_tweet(tweet)
  rescue StandardError => e
    logger.error "[#{Time.now.utc}] [TWITTER] [STREAMING] [ERROR] tweet id: #{tweet.id}: #{e.message}"
  end

  def on_delete_tweet(delete)
    logger.info "[#{Time.now.utc}] [TWITTER] [STREAMING] [DELETE] delete tweet received for id #{delete.id}"
    Tweet.find_by(tweet_id: delete.id)&.delete
  end

  def on_error(error)
    logger.error "[#{Time.now.utc}] [TWITTER] [STREAMING] [ERROR] #{error.message}"
  end

  def update_active_twitter_ids
    return if active_twitter_ids == fetch_active_twitter_ids

    self.active_twitter_ids = fetch_active_twitter_ids
    destroy_streaming_thread
    create_streaming_thread
  end

  def fetch_active_twitter_ids
    Rails.cache.fetch('active_twitter_ids',
                      expires_in: ACTIVE_TWITTER_IDS_POLLING_INTERVAL) do
      TwitterProfile.active_twitter_ids
    end
  end
end
