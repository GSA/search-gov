# frozen_string_literal: true

namespace :usasearch do
  namespace :twitter do
    desc 'prune tweets older than X days (default 3)'
    task :expire, [:days_back] => [:environment] do |_t, args|
      args.with_defaults(days_back: 3)
      Tweet.expire(args.days_back.to_i)
    end

    desc 'optimize the elastic_tweets index'
    task optimize_index: :environment do
      ElasticTweet.optimize
    end

    desc 'refresh twitter lists members'
    task :refresh_lists, [:host] => :environment do |_t, args|
      args.with_defaults(host: 'default')
      ContinuousWorker.start { TwitterData.refresh_lists }
    end

    desc 'refresh tweets from lists'
    task :refresh_lists_statuses, [:host] => :environment do |_t, args|
      args.with_defaults(host: 'default')
      ContinuousWorker.start { TwitterData.refresh_lists_statuses }
    end

    desc 'Connect to Twitter Streaming API and capture tweets from all customer twitter accounts'
    task stream: [:environment] do
      twitter_ids = SynchronizedObjectHolder.new do
        ActiveRecord::Base.connection.uncached { TwitterProfile.active_twitter_ids }
      end
      monitor = TwitterStreamingMonitor.new(twitter_ids)
      monitor.run
      sleep(0) while monitor.alive?
    end
  end
end
