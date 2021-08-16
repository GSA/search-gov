# frozen_string_literal: true

def mk_streaming_event(json)
  Twitter::Streaming::MessageParser.parse(
    JSON.parse(json, symbolize_names: true)
  )
end

describe TwitterStreamer do
  subject(:streamer) { described_class.new(logger) }

  let(:twitter_client) { Twitter::Streaming::Client.new }
  let(:logger) { ActiveSupport::Logger.new(Rails.root.join('log/twitter.log')) }

  before do
    allow(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
    allow(Twitter::Streaming::Client).to receive(:new).and_yield(twitter_client).and_return(twitter_client)
    allow(twitter_client).to receive(:close)
    allow(twitter_client).to receive(:filter)
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)

    Rails.application.secrets.twitter = {
      consumer_key: 'expected consumer_key',
      consumer_secret: 'expected consumer_secret',
      access_token: 'expected access_token',
      access_token_secret: 'expected access_token_secret'
    }
  end

  describe '#streaming_thread_body' do
    before { streamer.active_twitter_ids = [1, 2] }

    context 'when there are no errors' do
      let(:first_tweet) { Twitter::Tweet.new(id: 'first-tweet') }
      let(:second_tweet) { Twitter::Tweet.new(id: 'second-tweet') }

      before do
        allow(twitter_client).to receive(:filter).
          and_yield(first_tweet).
          and_yield(second_tweet)
        streamer.send(:streaming_thread_body)
      end

      it 'connects to twitter' do
        expect(twitter_client).to have_received(:filter).with(follow: '1,2')
      end

      it 'pushes the streamed tweets onto the event queue' do
        expect(streamer.event_queue.size).to eq(2)
        expect(streamer.event_queue.pop).to eq(first_tweet)
        expect(streamer.event_queue.pop).to eq(second_tweet)
      end
    end

    context 'when the client throws an error' do
      before { allow(twitter_client).to receive(:filter).and_raise(StandardError) }

      it 'does not propagate the exception' do
        expect { streamer.send(:streaming_thread_body) }.not_to raise_exception
      end

      it 'pushes the exception onto the event queue' do
        streamer.send(:streaming_thread_body)

        expect(streamer.event_queue.size).to eq(1)
        expect(streamer.event_queue.pop).to be_a(StandardError)
      end
    end
  end

  describe '#stream_tweets' do
    after { Rails.cache.clear }

    context 'when initializing' do
      before do
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])
        streamer.stream_tweets
      end

      it 'creates the twitter client using the credentials from Rails secrets' do
        expect(twitter_client.consumer_key).to eq('expected consumer_key')
        expect(twitter_client.consumer_secret).to eq('expected consumer_secret')
        expect(twitter_client.access_token).to eq('expected access_token')
        expect(twitter_client.access_token_secret).to eq('expected access_token_secret')
      end
    end

    context 'when we are waiting a while before connecting (e.g. after an error)' do
      let(:now) { Time.new.utc }

      before do
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])
        allow(streamer).to receive(:sleep)
        allow(Time).to receive(:now).and_return(now)
        allow(now).to receive(:utc).and_return(now)
        streamer.reconnect_time = now + 10.seconds
      end

      it 'sleeps for the correct time before connecting' do
        streamer.stream_tweets

        expect(streamer).to have_received(:sleep).with(10).ordered
        expect(twitter_client).to have_received(:filter).ordered
      end
    end

    context 'when it receives a tweet' do
      let(:saved_tweet) { Tweet.first }

      before do
        allow(twitter_client).to receive(:filter).and_yield(mk_streaming_event(file_fixture('json/tweet_status.json').read))
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])

        streamer.stream_tweets
      end

      it 'saves it' do
        expect(saved_tweet.tweet_id).to eq(258289885373423617)
        expect(saved_tweet.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
        expect(saved_tweet.twitter_profile_id).to eq(123)
        expect(saved_tweet.published_at).to eq(Time.rfc822('06 Apr 2011 19:13:37 UTC +00:00'))

        saved_urls = saved_tweet.urls.map(&:url)
        expect(saved_urls.size).to eq(2)
        expect(saved_urls).to include('http://t.co/l8VhWiZH') # from tweet urls
        expect(saved_urls).to include('http://t.co/y5YSDq7M') # from tweet media
      end
    end

    context 'when there is an error' do
      before do
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])
        allow(twitter_client).to receive(:filter).and_raise('error')
        streamer.stream_tweets
      end

      it 'shuts down the streaming thread' do
        expect(streamer.streaming_thread).to be_nil
      end

      it 'sets the error-wait timer' do
        expect(streamer.reconnect_time).to be > Time.now.utc
      end
    end

    context 'when it recieves a tweet from a user with no matching TwitterProfile' do
      before do
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])
        allow(twitter_client).to receive(:filter).and_yield(mk_streaming_event(file_fixture('json/tweet_status_from_not_followed.json').read))
        streamer.stream_tweets
      end

      it 'does not create a new tweet' do
        expect(Tweet.count).to eq(0)
      end
    end

    context 'when it recieves a tweet with incomplete URLs' do
      let(:saved_tweet) { Tweet.first }

      before do
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])
        allow(twitter_client).to receive(:filter).and_yield(mk_streaming_event(file_fixture('json/tweet_status_with_partial_urls.json').read))
        streamer.stream_tweets
      end

      it 'does only saves the complete urls' do
        expect(saved_tweet.urls.collect(&:display_url)).to eq(%w[pic.twitter.com/y5YSDq7M])
      end
    end

    context 'when it receives a retweet' do
      before do
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])
        allow(twitter_client).to receive(:filter).and_yield(mk_streaming_event(file_fixture('json/retweet_status.json').read))
        streamer.stream_tweets
      end

      it 'saves it' do
        saved_tweet = Tweet.first

        expect(saved_tweet.tweet_id).to eq(263164794574626816)
        expect(saved_tweet.tweet_text).to eq("RT @femaregion1: East Coast accounts giving specific #Sandy safety tips @femaregion1 @femaregion2 @FEMAregion3 @femaregion4 http://t.co/odIp5fl7\u2026")
        expect(saved_tweet.twitter_profile_id).to eq(123)
        expect(saved_tweet.published_at).to eq(Time.rfc822('28 Oct 2012 19:44:15 UTC +00:00'))
        expect(saved_tweet.urls.collect(&:display_url)).to eq(%w[fema.gov/colorbox/node/])
      end
    end

    context 'when it receives a delete-tweet' do
      let(:tweet_id) { 1234 }

      before do
        Tweet.create!(twitter_profile_id: 1,
                      tweet_id: tweet_id,
                      tweet_text: 'DELETE ME.',
                      published_at: Time.now.utc)
        delete_tweet = mk_streaming_event(
          %({"delete": { "status": { "id": #{tweet_id}, "user_id": 3 } } })
        )
        allow(twitter_client).to receive(:filter).and_yield(delete_tweet)
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123])

        streamer.stream_tweets
      end

      it 'deletes the tweet' do
        expect(Tweet.find_by(tweet_id: tweet_id)).to be_nil
      end
    end

    context 'when the twitter ids change' do
      before do
        described_class.const_set('ERROR_WAIT_TIME', 0.001)
        described_class.const_set('ACTIVE_TWITTER_IDS_POLLING_INTERVAL', 0.01)
        allow(TwitterProfile).to receive(:active_twitter_ids).and_return([1, 2], [3], [])
        allow(twitter_client).to receive(:filter) do
          loop { sleep(0) } # twitter id change will kill the streaming thread
        end
      end

      it 'connects and disconnects each time the ids change' do
        # We can't do this using spies and have_received
        # See https://github.com/rspec/rspec-mocks/issues/916
        expect(twitter_client).to receive(:filter).with(follow: '1,2').ordered
        expect(twitter_client).to receive(:close).ordered
        expect(twitter_client).to receive(:filter).with(follow: '3').ordered
        expect(twitter_client).to receive(:close).ordered

        streamer.stream_tweets
        streamer.stream_tweets
        streamer.stream_tweets
      end
    end
  end
end
