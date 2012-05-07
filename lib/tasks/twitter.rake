namespace :usasearch do
  namespace :twitter do
    
    desc "Connect to Twitter Streaming API and capture tweets from all customer twitter accounts"
    task :stream, :run_once, :needs => :environment do |t, args|
      run_once = args.run_once == "true" ? true : false
      logger = ActiveSupport::BufferedLogger.new(Rails.root.to_s + "/log/twitter.log")
      TweetStream.configure do |config|
        config.username = 'USASearch'
        config.password = '***REMOVED***'
        config.auth_method = :basic
        config.parser   = :json_gem
      end
      twitter_client = TweetStream.new
      twitter_client.on_delete do |status_id, user_id|
        logger.info "[TWITTER] Received delete request for status##{status_id}"
        Tweet.destroy_all(["tweet_id = ?", status_id])
      end
      twitter_client.on_error do |message|
        logger.error "[TWITTER] #{message}"
      end
      twitter_client.on_reconnect do |timeout, retries|
        logger.info "[TWITTER] Reconnecting at #{Time.now}..."
      end
      twitter_client.on_interval(3600) do
        logger.info "[TWITTER] Time has elapsed, shutting down connection."
        twitter_client.stop
      end
      loop do
        profile_ids = TwitterProfile.select(:twitter_id).collect(&:twitter_id)
        logger.info "[TWITTER] Connecting to Twitter to follow #{profile_ids.size} Twitter profiles."
        unless profile_ids.empty?
          twitter_client.follow(profile_ids) do |status, client|
            logger.info "[TWITTER] New tweet received: @#{status.user.screen_name}: #{status.text}"
            tweet = Tweet.create(:tweet_id => status.id, :tweet_text => status.text, :published_at => status.created_at, :twitter_profile_id => status.user.id) if profile_ids.include?(status.user.id)
          end
        end
        break if run_once
      end
    end
  end
end