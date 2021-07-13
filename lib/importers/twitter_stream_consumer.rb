# frozen_string_literal: true

class TwitterStreamConsumer
  attr_reader :twitter_ids
  attr_accessor :exit_flag, :consumer_thread

  def initialize(twitter_ids)
    @twitter_ids = twitter_ids
    @exit_flag = false
    @consumer_thread = nil
  end

  def follow
    return if twitter_ids.blank?

    Rails.logger.info "[#{Time.now.utc}] [TWITTER] [FOLLOW] Connecting to Twitter to follow #{twitter_ids.size} Twitter profiles."
    self.consumer_thread = Thread.new do
      Rails.application.executor.wrap { consumer_thread_body }
    end
  end

  def stop
    self.exit_flag = true
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads {consumer_thread&.join}
    self.consumer_thread = nil
  end

  def alive?
    consumer_thread&.alive?
  end

  private

  def consumer_thread_body
    twitter_client.filter(follow: twitter_ids.join(',')) do |twitter_event|
      dispatch(twitter_event)
      break if exit_flag
    end
  rescue StandardError => e
    Rails.logger.error "[#{Time.now.utc}] [TWITTER] Error streaming Twitter: #{e.message}"
  ensure
    ActiveRecord::Base.clear_active_connections!
  end

  def dispatch(twitter_event)
    case twitter_event
    when Twitter::Tweet
      on_tweet(twitter_event)
    when Twitter::Streaming::DeletedTweet
      on_deleted_tweet(twitter_event)
    end
  end

  def twitter_client
    return @twitter_client if @twitter_client

    @twitter_client = Twitter::Streaming::Client.new do |config|
      Rails.application.secrets.twitter.each do |key, value|
        config.send("#{key}=", value)
      end
    end

    @twitter_client.before_request do
      Rails.logger.info "[#{Time.now.utc}] [TWITTER] [CONNECT] Connected."
    end

    @twitter_client
  end

  def on_tweet(tweet)
    Rails.logger.info "[#{Time.now.utc}] [TWITTER] [FOLLOW] Tweet received: @#{tweet.user.screen_name}: #{tweet.text}"
    TwitterData.import_tweet(tweet)
  rescue StandardError => e
    Rails.logger.error "[#{Time.now.utc}] [TWITTER] [FOLLOW] [ERROR] encountered error while handling tweet##{tweet.id}: #{e.message}"
  end

  def on_deleted_tweet(tweet)
    Rails.logger.info "[#{Time.now.utc}] [TWITTER] [DELETE] Received delete request for tweet##{tweet.id}"
    begin
      Tweet.where(tweet_id: tweet.id).destroy_all
    rescue StandardError => e
      Rails.logger.error "[#{Time.now.utc}] [TWITTER] [FOLLOW] [ERROR] encountered error while deleting tweet##{tweet.id}: #{e.message}"
    end
  end
end
