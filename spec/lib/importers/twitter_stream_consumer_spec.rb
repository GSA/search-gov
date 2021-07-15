# frozen_string_literal: true

RSpec.describe TwitterStreamConsumer do
  subject(:consumer) { described_class.new(active_twitter_ids) }

  let(:active_twitter_ids) { [] }
  let(:client) { Twitter::Streaming::Client.new }
  let(:filter_yield_values) { [] }

  def follow
    allow(Twitter::Streaming::Client).to receive(:new).and_yield(client).and_return(client)
    allow(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
    allow(client).to receive(:filter) do |&block|
      filter_yield_values.each do |twitter_event|
        block.call(twitter_event)
      end
      loop do
        block.call(nil)
      end
    end

    consumer.follow
    sleep(0.1)
  end

  describe '#follow' do
    after { consumer.stop }

    context 'when there are no live twitter ids' do
      before { follow }

      it 'does not start the consumer thread' do
        expect(consumer.consumer_thread).to be_nil
      end
    end

    context 'when there are live twitter ids' do
      let(:active_twitter_ids) { [1, 2, 3] }

      before { follow }

      it 'starts the consumer thread' do
        expect(consumer.consumer_thread).not_to be_nil
      end
    end

    context 'processing a tweet' do
      let(:tweet_json) do
        JSON.parse(file_fixture('json/tweet_status.json').read,
                   symbolize_names: true)
      end
      let(:active_twitter_ids) { [tweet_json[:user][:id]] }
      let(:filter_yield_values) { [Twitter::Tweet.new(tweet_json)] }

      context 'when there is no error' do
        before { follow }

        it 'creates exactly one Tweet' do
          expect(Tweet.count).to eq(1)
        end

        it 'saves the profile id' do
          expect(Tweet.first.twitter_profile_id).to eq(tweet_json[:user][:id])
        end

        it 'saves the published_at time' do
          expect(Tweet.first.published_at).to eq(tweet_json[:created_at])
        end

        it 'saves the tweet text' do
          expect(Tweet.first.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
        end

        it 'saves the tweet urls' do
          expect(Tweet.first.urls.collect(&:display_url)).to eq(%w[search.gov/features pic.twitter.com/y5YSDq7M])
        end
      end

      context 'when there is an error' do
        before do
          allow(TwitterData).to receive(:import_tweet).and_raise('Some error')
          follow
        end

        it 'does not save the tweet' do
          expect(Tweet.count).to eq(0)
        end
      end
    end

    context 'processing a re-tweet' do
      let(:tweet_json) do
        JSON.parse(file_fixture('json/retweet_status.json').read,
                   symbolize_names: true)
      end
      let(:active_twitter_ids) { [tweet_json[:user][:id]] }
      let(:filter_yield_values) { [Twitter::Tweet.new(tweet_json)] }

      context 'when there is no error saving the re-tweet' do
        before { follow }

        it 'creates exactly one Tweet' do
          expect(Tweet.count).to eq(1)
        end

        it 'saves the profile id' do
          expect(Tweet.first.twitter_profile_id).to eq(tweet_json[:user][:id])
        end

        it 'saves the published_at time' do
          expect(Tweet.first.published_at).to eq(tweet_json[:retweeted_status][:created_at])
        end

        it 'saves the tweet text' do
          expect(Tweet.first.tweet_text).to match(/RT @femaregion1: East Coast accounts giving specific #Sandy safety tips/)
        end

        it 'saves the tweet urls' do
          expect(Tweet.first.urls.collect(&:display_url)).to eq(['fema.gov/colorbox/node/'])
        end
      end

      context 'when there is an error saving the re-tweet' do
        before do
          allow(TwitterData).to receive(:import_tweet).and_raise('Some error')
          follow
        end

        it 'does not save the re-tweet' do
          expect(Tweet.count).to eq(0)
        end
      end
    end

    context 'processing a delete-tweet' do
      let(:active_twitter_ids) { [1] }
      let(:filter_yield_values) { [Twitter::Streaming::DeletedTweet.new({ id: 1234 })] }

      before do
        Tweet.create!(twitter_profile_id: 1,
                      tweet_id: 1234,
                      tweet_text: 'DELETE ME.',
                      published_at: Time.now.utc)
        follow
      end

      it 'deletes the tweet' do
        expect(Tweet.count).to eq(0)
      end
    end
  end

  describe '#stop' do
    let(:active_twitter_ids) { [8, 6, 7] }
    let(:client) { Twitter::Streaming::Client.new }

    before do
      consumer.instance_variable_set(:@twitter_client, client)
      allow(client).to receive(:filter).and_yield('junk')

      consumer.follow
      consumer.stop
    end

    it 'stops the consumer thread' do
      expect(consumer.consumer_thread).to be_nil
    end
  end
end
