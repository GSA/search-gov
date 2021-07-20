# frozen_string_literal: true

shared_context 'when tweet processing throws an error' do
  before do
    allow(TwitterData).to receive(:import_tweet).and_raise 'An Error'
    run_task
  end
end

shared_examples "depends on 'environment'" do
  it "has 'environment' as a prereq" do
    expect(Rake.application[task_name].prerequisites).to include('environment')
  end
end

describe 'Twitter rake tasks' do
  before :all do
    Rake.application = Rake::Application.new
    Rake.application.rake_require('tasks/twitter')
    Rake::Task.define_task(:environment)
  end

  before { Rake.application[task_name].reenable }

  describe 'usasearch:twitter' do
    describe 'usasearch:twitter:expire' do
      let(:task_name) { 'usasearch:twitter:expire' }

      include_examples "depends on 'environment'"

      context 'when days back is specified' do
        let(:days_back) { 7 }

        before { allow(Tweet).to receive(:expire) }

        it 'expires tweets that were published more than X days ago' do
          Rake.application[task_name].invoke(days_back)
          expect(Tweet).to have_received(:expire).with(days_back)
        end
      end

      context 'when days back is not specified' do
        let(:default_days_back) { 3 }

        before { allow(Tweet).to receive(:expire) }

        it 'expires tweets that were published more than 3 days ago' do
          Rake.application[task_name].invoke
          expect(Tweet).to have_received(:expire).with(default_days_back)
        end
      end
    end

    describe 'usasearch:twitter:optimize_index' do
      let(:task_name) { 'usasearch:twitter:optimize_index' }

      before do
        allow(ElasticTweet).to receive(:optimize)
      end

      include_examples "depends on 'environment'"

      it 'calls ElasticTweet.optimize' do
        Rake.application[task_name].invoke
        expect(ElasticTweet).to have_received :optimize
      end
    end

    describe 'usasearch:twitter:refresh_lists' do
      let(:task_name) { 'usasearch:twitter:refresh_lists' }

      before do
        allow(ContinuousWorker).to receive(:start).and_yield
        allow(TwitterData).to receive(:refresh_lists)
      end

      include_examples "depends on 'environment'"

      context 'when run' do
        before { Rake.application[task_name].invoke }

        it 'calls TwitterData.refresh_lists' do
          expect(TwitterData).to have_received(:refresh_lists)
        end
      end
    end

    describe 'usasearch:twitter:refresh_lists_statuses' do
      let(:task_name) { 'usasearch:twitter:refresh_lists_statuses' }

      include_examples "depends on 'environment'"

      context 'when run' do
        before do
          allow(ContinuousWorker).to receive(:start).and_yield
          allow(TwitterData).to receive(:refresh_lists_statuses)
          Rake.application[task_name].invoke
        end

        it 'calls TwitterData.refresh_lists_statuses' do
          expect(TwitterData).to have_received(:refresh_lists_statuses)
        end
      end
    end

    describe 'usasearch:twitter:stream' do
      let(:task_name) { 'usasearch:twitter:stream' }
      let(:active_twitter_ids) { [] }
      let(:client) { Twitter::Streaming::Client.new }
      let(:filter_yield_values) { [] }
      let(:logger) { Logger.new('twitter.log') }

      def run_task
        reaper = Thread.new do
          sleep(0.5)
          TwitterStreamingMonitor.monitor.stop
        end
        Rake.application[task_name].invoke
        reaper.join
      end

      before do
        Rake.application[task_name].reenable
        allow(Twitter::Streaming::Client).to receive(:new).and_yield(client).and_return(client)
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return(active_twitter_ids)
        allow(Logger).to receive(:new).and_return(logger)
        allow(logger).to receive(:info).and_call_original
        allow(logger).to receive(:error).and_call_original
        allow(client).to receive(:filter) do |&block|
          filter_yield_values.each do |twitter_event|
            block.call(twitter_event)
            sleep(0)
          end
          loop do
            block.call(nil)
            sleep(0)
          end
        end
        allow(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)

        require_dependency 'twitter_streaming_monitor'
        stub_const('TwitterStreamingMonitor::POLLING_INTERVAL', 0.001)
      end

      include_examples "depends on 'environment'"

      context 'when configuring the Twitter client' do
        let(:active_twitter_ids) { [1234] } # we won't create a client without ids

        before do
          allow(Rails.application.secrets).to receive(:twitter).
            and_return(
              {
                'consumer_key' => 'expected_consumer_key',
                'consumer_secret' => 'expected_consumer_secret',
                'access_token' => 'expected_access_token',
                'access_token_secret' => 'expected_access_secret'
              }
            )
          run_task
        end

        it 'configures the twitter client using the twitter secrets info' do
          expect(client.consumer_key).to eq('expected_consumer_key')
          expect(client.consumer_secret).to eq('expected_consumer_secret')
          expect(client.access_token).to eq('expected_access_token')
          expect(client.access_token_secret).to eq('expected_access_secret')
        end
      end

      context 'when starting' do
        it 'starts up the streaming monitor' do
          run_task
          expect(logger).to have_received(:info).with(/\[TWITTER\] \[MONITOR\] twitter_ids: \[/).at_least(:once)
        end

        context 'when there are active twitter ids' do
          let(:active_twitter_ids) { [1] }

          before { run_task }

          it 'starts the tweet consumer' do
            expect(logger).to have_received(:info).with(/\[TWITTER\] \[CONNECTING\]/).at_least(:once)
          end
        end

        context 'when there are no active twitter ids' do
          let(:active_twitter_ids) { [] }

          before { run_task }

          it 'does not start the tweet consumer' do
            expect(logger).not_to have_received(:info).with(/\[TWITTER\] \[CONNECTING\]/)
          end
        end
      end

      context 'when processing a tweet' do
        let(:filter_yield_values) do
          [
            Twitter::Tweet.new(JSON.parse(file_fixture('json/tweet_status.json').read,
                                          symbolize_names: true))
          ]
        end
        let(:active_twitter_ids) { [filter_yield_values.first.user.id] }

        context 'when there is no error' do
          before { run_task }

          it 'creates exactly one Tweet' do
            expect(Tweet.count).to eq(1)
          end

          it 'saves the tweet text' do
            expect(Tweet.first.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
          end

          it 'saves the tweet urls' do
            expect(Tweet.first.urls.collect(&:display_url)).to eq(%w[search.gov/features pic.twitter.com/y5YSDq7M])
          end
        end

        context 'when there is an error' do
          include_context 'when tweet processing throws an error'

          it 'logs an error' do
            expect(logger).to have_received(:error).
              with(/\[TWITTER\] \[FOLLOW\] \[ERROR\].*error while handling tweet#[[:digit:]]+: An Error/).at_least(:once)
          end
        end

        context 'when there are changes to the active twitter ids' do
          before do
            allow(TwitterProfile).to receive(:active_twitter_ids).and_return(
              [1, 2],
              [1, 2],
              [1, 2],
              [1, 2, 3],
              [1, 2, 3],
              [1, 2, 3],
              [],
              [],
              []
            )
            run_task
          end

          it 'disconnects' do
            expect(logger).to have_received(:info).with(/\[TWITTER\] \[DISCONNECT\]/).at_least(2).times
          end

          it 'reconnects' do
            expect(logger).to have_received(:info).with(/\[TWITTER\] \[CONNECTING\]/).once
          end
        end
      end

      context 'when processing a retweet' do
        let(:filter_yield_values) do
          [
            Twitter::Tweet.new(JSON.parse(file_fixture('json/retweet_status.json').read,
                                          symbolize_names: true))
          ]
        end
        let(:active_twitter_ids) { [filter_yield_values.first.user.id] }

        context 'when there is no error' do
          before { run_task }

          it 'creates exactly one Tweet' do
            expect(Tweet.count).to eq(1)
          end

          it 'saves the tweet text' do
            expect(Tweet.first.tweet_text).to match(/East Coast accounts giving specific #Sandy safety tips/)
          end

          it 'saves the tweet urls' do
            expect(Tweet.first.urls.collect(&:display_url)).to eq(['fema.gov/colorbox/node/'])
          end
        end

        context 'when there is an error' do
          include_context 'when tweet processing throws an error'

          it 'logs the error' do
            expect(logger).to have_received(:error).
              with(/encountered error while handling tweet#[[:digit:]]+: An Error/).at_least(:once)
          end
        end
      end

      context 'when processing a delete-tweet' do
        let(:active_twitter_ids) { [1] }
        let(:filter_yield_values) { [Twitter::Streaming::DeletedTweet.new({ id: 1234 })] }

        before do
          Tweet.create!(twitter_profile_id: 1,
                        tweet_id: 1234,
                        tweet_text: 'DELETE ME.',
                        published_at: Time.now.utc)
        end

        context 'when there is no error' do
          before { run_task }

          it 'deletes the saved tweet' do
            expect(Tweet.find_by(tweet_id: 1234)).to be_nil
          end

          it 'logs the deletion' do
            expect(logger).to have_received(:info).
              with(/\[TWITTER\] \[DELETE\]/).at_least(:once)
          end
        end

        context 'when there is an error' do
          before do
            allow(Tweet).to receive(:where).and_raise('An Error')
            run_task
          end

          it 'logs the error' do
            expect(logger).to have_received(:error).
              with(/\[TWITTER\] \[FOLLOW\] \[ERROR\].*error while deleting tweet#1234/).
              at_least(:once)
          end
        end
      end
    end
  end
end
