# frozen_string_literal: true

shared_context 'when tweet processing throws an error' do
  before do
    allow(TwitterData).to receive(:import_tweet).and_raise 'An Error'
    run_task
  end
end

describe 'Twitter rake tasks' do
  before :all do
    Rake.application = Rake::Application.new
    Rake.application.rake_require('tasks/twitter')
    Rake::Task.define_task(:environment)
  end

  let(:task_name) { nil }

  before { Rake.application[task_name].reenable }

  describe 'usasearch:twitter' do
    describe 'usasearch:twitter:expire' do
      let(:task_name) { 'usasearch:twitter:expire' }

      it "has 'environment' as a prereq" do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

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

      it 'has environment as a prereq' do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

      context 'when run' do
        before { Rake.application[task_name].invoke }

        it 'calls TwitterData.refresh_lists' do
          expect(TwitterData).to have_received(:refresh_lists)
        end
      end
    end

    describe 'usasearch:twitter:refresh_lists_statuses' do
      let(:task_name) { 'usasearch:twitter:refresh_lists_statuses' }

      it 'has environment as a prereq' do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

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

      def run_task
        Rake.application[task_name].invoke
        sleep(0.2)
        TwitterStreamingMonitor.stop
      end

      before do
        Rake.application[task_name].reenable
        allow(Twitter::Streaming::Client).to receive(:new).and_yield(client).and_return(client)
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return(active_twitter_ids)
        allow(Rails.logger).to receive(:info).and_call_original
        allow(Rails.logger).to receive(:error).and_call_original

        # Without this require, there's a timing dependency that
        # causes stub_const to sometimes blow up the specs. If
        # twitter_streaming_monitor.rb hasn't been loaded yet, then
        # the stub_const will define TwitterStreamingMonitor as a
        # module, not a class. Things get ugly after
        # that.
        require 'twitter_streaming_monitor'
        stub_const('TwitterStreamingMonitor::POLLING_INTERVAL', 0.01)
      end

      it "has 'environment' as a prereq" do
        expect(Rake.application[task_name].prerequisites).to include('environment')
      end

      context 'when configuring Twitter' do
        let(:auth_info) do
          {
            'consumer_key' => 'default_consumer_key',
            'consumer_secret' => 'default_consumer_secret',
            'access_token' => 'default_access_token',
            'access_token_secret' => 'default_access_secret'
          }
        end

        let(:active_twitter_ids) { [1234] }

        before do
          allow(client).to receive(:consumer_key=).and_call_original
          allow(client).to receive(:consumer_secret=).and_call_original
          allow(client).to receive(:access_token).and_call_original
          allow(client).to receive(:access_token_secret=).and_call_original
          allow(Rails.application.secrets).to receive(:twitter).and_return(auth_info)

          run_task
        end

        it 'uses the twitter secrets info' do
          expect(Rails.application.secrets).to have_received(:twitter).at_least(:once)
          expect(client.consumer_key).to eq('default_consumer_key')
          expect(client.consumer_secret).to eq('default_consumer_secret')
          expect(client.access_token).to eq('default_access_token')
          expect(client.access_token_secret).to eq('default_access_secret')
        end
      end

      context 'when starting' do
        it 'starts up the streaming monitor' do
          run_task
          expect(Rails.logger).to have_received(:info).with(/\[TWITTER\] \[MONITOR START\]/).at_least(:once)
        end

        context 'when there are active twitter ids' do
          let(:active_twitter_ids) { [1] }

          before { run_task }

          it 'starts the tweet consumer' do
            expect(Rails.logger).to have_received(:info).with(/\[TWITTER\] \[CONNECT\]/).at_least(:once)
          end
        end

        context 'when there are no active twitter ids' do
          let(:active_twitter_ids) { [] }

          before { run_task }

          it 'does not start the tweet consumer' do
            expect(Rails.logger).not_to have_received(:info).with(/\[TWITTER\] \[CONNECT\]/)
          end
        end
      end

      context 'when processing a tweet' do
        let(:tweet_json) { File.read(Rails.root.join('spec/fixtures/json/tweet_status.json')) }
        let(:active_twitter_ids) { [JSON.parse(tweet_json)['user']['id']] }

        before do
          allow(client).to receive(:filter).and_yield(Twitter::Tweet.new(JSON.parse(tweet_json, symbolize_names: true)))
          allow(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
        end

        context 'when there is no error' do
          let(:tweet) { Tweet.first }

          before { run_task }

          it 'creates exactly one Tweet' do
            expect(Tweet.count).to eq(1)
          end

          it 'saves the tweet text' do
            expect(tweet.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
          end

          it 'saves the tweet urls' do
            expect(tweet.urls.collect(&:display_url)).to eq(%w[search.gov/features pic.twitter.com/y5YSDq7M])
          end
        end

        context 'when there is an error' do
          include_context 'when tweet processing throws an error'

          it 'logs an error' do
            expect(Rails.logger).to have_received(:error).
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
            expect(Rails.logger).to have_received(:info).with(/\[TWITTER\] \[DISCONNECT\]/).at_least(2).times
          end

          it 'reconnects' do
            expect(Rails.logger).to have_received(:info).with(/\[TWITTER\] \[CONNECT\]/).at_least(2).times
          end
        end
      end

      context 'when processing a retweet' do
        let(:tweet_json) do
          JSON.parse(File.read(Rails.root.join('spec/fixtures/json/retweet_status.json')),
                     symbolize_names: true)
        end
        let(:active_twitter_ids) { [tweet_json[:retweeted_status][:user][:id]] }
        let(:retweet) { Twitter::Tweet.new(tweet_json) }

        before do
          allow(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
          allow(client).to receive(:filter).and_yield(retweet)
        end

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
            expect(Rails.logger).to have_received(:error).
              with(/encountered error while handling tweet#[[:digit:]]+: An Error/).at_least(:once)
          end
        end
      end

      context 'when processing a delete-tweet' do
        let(:active_twitter_ids) { [1] }
        let(:delete_tweet) do
          Twitter::Streaming::DeletedTweet.new({ id: 1234 })
        end

        before do
          Tweet.create!(twitter_profile_id: 1,
                        tweet_id: 1234,
                        tweet_text: 'DELETE ME.',
                        published_at: Time.now.utc)
          allow(client).to receive(:filter).and_yield(delete_tweet)
        end

        context 'when there is no error' do
          before { run_task }

          it 'deletes the saved tweet' do
            expect(Tweet.find_by(tweet_id: 1234)).to be_nil
          end

          it 'logs the deletion' do
            expect(Rails.logger).to have_received(:info).
              with(/\[TWITTER\] \[DELETE\]/).
              at_least(:once)
          end
        end

        context 'when there is an error' do
          before do
            allow(Tweet).to receive(:where).and_raise('An Error')
            run_task
          end

          it 'logs the error' do
            expect(Rails.logger).to have_received(:error).
              with(/\[TWITTER\] \[FOLLOW\] \[ERROR\].*error while deleting tweet#1234/).
              at_least(:once)
          end
        end
      end
    end
  end
end
j
