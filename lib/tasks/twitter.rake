namespace :usasearch do
  namespace :twitter do

    desc 'prune tweets older than X days (default 3)'
    task :expire, [:days_back] => [:environment] do |_t, args|
      args.with_defaults(days_back: 3)
      Tweet.expire(args.days_back.to_i)
    end

    desc 'optimize the elastic_tweets index'
    task :optimize_index => :environment do
      ElasticTweet.optimize
    end

    desc 'refresh twitter lists members'
    task :refresh_lists, [:host] => :environment do |_t, args|
      args.with_defaults host: 'default'
      ContinuousWorker.start { TwitterData.refresh_lists }
    end

    desc 'refresh tweets from lists'
    task :refresh_lists_statuses, [:host] => :environment do |_t, args|
      args.with_defaults host: 'default'
      ContinuousWorker.start { TwitterData.refresh_lists_statuses }
    end

    desc "Connect to Twitter Streaming API and capture tweets from all customer twitter accounts"
    task :stream => [:environment] do
      logger = ActiveSupport::Logger.new(Rails.root.to_s + "/log/twitter.log")
      TweetStream.configure do |config|
        config_hash = Rails.application.secrets.twitter.merge(
          Rails.application.config_for(:tweetstream)
        )
        config_hash.each do |key, value|
          config.send("#{key}=", value)
        end
      end

      twitter_ids_holder = SynchronizedObjectHolder.new { TwitterProfile.active_twitter_ids }

      EM.run do
        twitter_client = TweetStream::Client.new

        twitter_client.on_error { |message| logger.error "[#{Time.now}] [TWITTER] [ERROR] #{message}" }
        twitter_client.on_limit { |skip_count| logger.info "[#{Time.now}] [TWITTER] [LIMIT] skip count: #{skip_count}" }

        twitter_client.on_reconnect do |timeout, retries|
          logger.info "[#{Time.now}] [TWITTER] [RECONNECT] Reconnecting timeout: #{timeout} retries: #{retries}"
        end

        twitter_client.on_delete do |status_id, user_id|
          logger.info "[#{Time.now}] [TWITTER] [ONDELETE] Received delete request for status##{status_id}"
          Tweet.where(:tweet_id => status_id).destroy_all
        end

        do_follow = lambda do |twitter_client|
          twitter_ids = twitter_ids_holder.get_object_and_reset_changed
          if twitter_ids.present?
            logger.info "[#{Time.now}] [TWITTER] [CONNECT] Connecting to Twitter to follow #{twitter_ids.size} Twitter profiles."

            twitter_client.follow(twitter_ids) do |status|
              logger.info "[#{Time.now}] [TWITTER] [FOLLOW] New tweet received: @#{status.user.screen_name}: #{status.text}"
              begin
                TwitterData.import_tweet(status) if twitter_ids.include?(status.user.id)
              rescue Exception => e
                logger.error "[#{Time.now}] [TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=#{status.id}: #{e.message}"
              end
            end
          end
        end

        do_follow.call(twitter_client)

        EventMachine.add_periodic_timer(60) do
          if twitter_ids_holder.object_changed?
            logger.info "[#{Time.now}] [TWITTER] [RESET_STREAM]"
            twitter_client.stop_stream
            do_follow.call(twitter_client)
          end
        end
      end
    end
  end
end
