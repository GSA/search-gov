namespace :usasearch do
  namespace :twitter do

    desc "Connect to Twitter Streaming API and capture tweets from all customer twitter accounts"
    task :stream => [:environment] do
      logger = ActiveSupport::BufferedLogger.new(Rails.root.to_s + "/log/twitter.log")
      TweetStream.configure do |config|
        config.consumer_key = '***REMOVED***'
        config.consumer_secret = '***REMOVED***'
        config.oauth_token = '***REMOVED***'
        config.oauth_token_secret = '***REMOVED***'
        config.auth_method = :oauth
      end

      EM.run do
        twitter_client = TweetStream::Client.new

        twitter_client.on_error { |message| logger.error "[#{Time.now}] [TWITTER] [ERROR] #{message}" }
        twitter_client.on_limit { |skip_count| logger.info "[#{Time.now}] [TWITTER] [LIMIT] skip count: #{skip_count}" }

        twitter_client.on_reconnect do |timeout, retries|
          logger.info "[#{Time.now}] [TWITTER] [RECONNECT] Reconnecting timeout: #{timeout} retries: #{retries}"
        end

        twitter_client.on_delete do |status_id, user_id|
          logger.info "[#{Time.now}] [TWITTER] [ONDELETE] Received delete request for status##{status_id}"
          Tweet.destroy_all(:tweet_id => status_id)
        end

        do_follow = lambda do |twitter_client|
          twitter_ids = TwitterProfile.twitter_ids_as_array
          if twitter_ids.present?
            logger.info "[#{Time.now}] [TWITTER] [CONNECT] Connecting to Twitter to follow #{twitter_ids.size} Twitter profiles."

            twitter_client.follow(twitter_ids) do |status|
              logger.info "[#{Time.now}] [TWITTER] [FOLLOW] New tweet received: @#{status.user.screen_name}: #{status.text}"
              begin
                Tweet.create(:tweet_id => status.id,
                             :tweet_text => status.text,
                             :published_at => status.created_at,
                             :twitter_profile_id => status.user.id,
                             :urls => status.urls) if TwitterProfile.exists?(:twitter_id => status.user.id)
              rescue Exception => e
                logger.error "[#{Time.now}] [TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=#{status.id}: #{e.message}"
              end
            end
          end
        end

        do_follow.call(twitter_client)

        EventMachine.add_periodic_timer(300) do
          logger.info "[#{Time.now}] [TWITTER] [RESET_STREAM]"
          twitter_client.stop_stream
          do_follow.call(twitter_client)
        end
      end
    end
  end
end
