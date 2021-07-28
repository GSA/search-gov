# frozen_string_literal: true

require 'spec_helper'

describe 'Twitter rake tasks' do
  before(:all) do
    Rake.application = Rake::Application.new
    Rake.application.rake_require('tasks/twitter')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:twitter' do
    describe 'usasearch:twitter:expire' do
      let(:task_name) { 'usasearch:twitter:expire' }

      before { Rake.application[task_name].reenable }

      it "has 'environment' as a prereq" do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

      context 'when days back is specified' do
        let(:days_back) { 7 }

        before do
          allow(Tweet).to receive(:expire)
          Rake.application[task_name].invoke(days_back)
        end

        it 'expires tweets that were published more than days back days ago' do
          expect(Tweet).to have_received(:expire).with(days_back.to_i)
        end
      end

      context 'when days back is not specified' do
        before do
          allow(Tweet).to receive(:expire)
          Rake.application[task_name].invoke
        end

        it 'expires tweets that were published more than 3 days ago' do
          expect(Tweet).to have_received(:expire).with(3)
        end
      end
    end

    describe 'usasearch:twitter:optimize_index' do
      let(:task_name) { 'usasearch:twitter:optimize_index' }

      before do
        allow(ElasticTweet).to receive(:optimize)
        Rake.application[task_name].invoke
      end

      it 'calls ElasticTweet.optimize' do
        expect(ElasticTweet).to have_received(:optimize)
      end
    end

    describe 'usasearch:twitter:refresh_lists' do
      let(:task_name) { 'usasearch:twitter:refresh_lists' }

      before do
        allow(ContinuousWorker).to receive(:start).and_yield
        allow(TwitterData).to receive(:refresh_lists)
        Rake.application[task_name].reenable
      end

      it 'has environment as a prereq' do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

      it 'starts a continuous worker' do
        Rake.application[task_name].invoke

        expect(TwitterData).to have_received(:refresh_lists)
      end
    end

    describe 'usasearch:twitter:refresh_lists_statuses' do
      let(:task_name) { 'usasearch:twitter:refresh_lists_statuses' }

      before do
        allow(ContinuousWorker).to receive(:start).and_yield
        allow(TwitterData).to receive(:refresh_lists_statuses)
        Rake.application[task_name].reenable
      end

      it 'has environment as a prereq' do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

      it 'starts a continuous worker' do
        Rake.application[task_name].invoke

        expect(TwitterData).to have_received(:refresh_lists_statuses)
      end
    end

    describe 'usasearch:twitter:stream' do
      let(:task_name) { 'usasearch:twitter:stream' }
      let(:logger) { ActiveSupport::Logger.new(Rails.root.join('log/twitter.log')) }
      let(:twitter_client) { Twitter::Streaming::Client.new }
      let(:active_twitter_ids) { [123].freeze }

      before do
        allow(logger).to receive(:info)
        allow(logger).to receive(:error)
        allow(ActiveSupport::Logger).to receive(:new).with(Rails.root.join('log/twitter.log')).and_return logger
        allow(Twitter::Streaming::Client).to receive(:new).and_return(twitter_client)
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return(active_twitter_ids)

        Rake.application[task_name].reenable
      end

      def invoke_task
        task_thread = Thread.new do
          Rails.application.executor.wrap do
            Rake.application[task_name].invoke
          end
        end
        sleep(1)
        task_thread.kill
        task_thread.join
      end

      it "has 'environment' as a prereq" do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

      it 'follows the specified ids' do
        invoke_task
        expect(logger).to have_received(:info).with(/^\[.*\] \[TWITTER\] \[CONNECT\] Connecting to Twitter to follow 1 profiles: \[123\]\.$/).at_least(:once)
      end

      context 'when it recieves a tweet' do
        let(:tweet_status_json) do
          JSON.parse(file_fixture('json/tweet_status.json').read, symbolize_names: true)
        end

        before do
          cooked_tweet = Twitter::Streaming::MessageParser.parse(tweet_status_json)
          allow(twitter_client).to receive(:filter).and_yield(cooked_tweet)
          allow(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
        end

        it 'logs receiving the tweet' do
          invoke_task
          expect(logger).to have_received(:info).with(%r{^\[.*\] \[TWITTER\] \[STREAMING\] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http://t.co/l8VhWiZH http://t.co/y5YSDq7M$}).at_least(:once)
        end

        it 'saves the tweet' do
          invoke_task
          expect(Tweet.count).to eq(1)
          tweet = Tweet.first
          expect(tweet.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
          expect(tweet.urls.collect(&:display_url)).to eq(%w[search.gov/features pic.twitter.com/y5YSDq7M])
        end

        context 'when something goes wrong saving the tweet' do
          before do
            allow(TwitterData).to receive(:import_tweet).and_raise 'an exception'
            invoke_task
          end

          it 'logs the error' do
            expect(logger).to have_received(:error).with(/^\[.*\] \[TWITTER\] \[STREAMING\] \[ERROR\] tweet id: 258289885373423617: an exception$/).at_least(:once)
          end
        end

        context 'when an error occurs while streaming' do
          it 'logs the error message' do
            allow(twitter_client).to receive(:filter).and_raise('some streaming error')
            invoke_task

            expect(logger).to have_received(:error).with(/\[.*\] \[TWITTER\] \[STREAMING\] \[ERROR\] some streaming error/).at_least(:once)
          end
        end
      end

      context 'when it receives a delete-tweet message' do
        let(:tweet_id) { 31416 }

        before do
          Tweet.create!(twitter_profile_id: 1,
                        tweet_id: tweet_id,
                        tweet_text: 'to be deleted',
                        published_at: Time.now.utc)

          delete_tweet = Twitter::Streaming::MessageParser.parse(
            JSON.parse(%({"delete": { "status": { "id": #{tweet_id}, "user_id": 3 } } }),
                       symbolize_names: true)
          )
          allow(twitter_client).to receive(:filter).and_yield(delete_tweet)
          invoke_task
        end

        it 'deletes the tweet' do
          expect(Tweet.count).to eq(0)
        end

        it 'logs the delete' do
          expect(logger).to have_received(:info).with(/^\[.*\] \[TWITTER\] \[STREAMING\] \[DELETE\] delete tweet received for id #{tweet_id}$/).at_least(:once)
        end
      end
    end
  end
end
