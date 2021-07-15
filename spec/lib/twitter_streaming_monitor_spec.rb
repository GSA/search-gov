# frozen_string_literal: true

describe TwitterStreamingMonitor do
  subject(:monitor) { described_class.new(twitter_ids_holder) }

  let(:client) { Twitter::Streaming::Client.new }

  twitter_ids = [] # needs to be a variable so the block in the next let works.
  let(:twitter_ids_holder) { SynchronizedObjectHolder.new { twitter_ids } }

  after { monitor.stop }

  before do
    require_dependency 'twitter_streaming_monitor'
    stub_const('TwitterStreamingMonitor::POLLING_INTERVAL', 0.001) # speed up the tests

    allow(Twitter::Streaming::Client).to receive(:new).and_yield(client).and_return(client)
    allow(client).to receive(:filter) do |&block|
      loop do
        block.call(nil)
        sleep(0)
      end
    end
  end

  context 'when initally created' do
    it 'does not have a monitor thread' do
      expect(monitor.monitor_thread).to be_nil
    end

    it 'does not have a stream thread' do
      expect(monitor.tweet_consumer).to be_nil
    end
  end

  describe 'configuration' do
    let(:auth_info) do
      {
        'consumer_key' => 'expected_consumer_key',
        'consumer_secret' => 'expected_consumer_secret',
        'access_token' => 'expected_access_token',
        'access_token_secret' => 'expected_access_secret'
      }
    end

    before do
      allow(Rails.application.secrets).to receive(:twitter).and_return(auth_info)
      twitter_ids = [1]
      monitor.run
      sleep(0.01)
    end

    it 'uses the twitter secrets info' do
      expect(client.consumer_key).to eq('expected_consumer_key')
      expect(client.consumer_secret).to eq('expected_consumer_secret')
      expect(client.access_token).to eq('expected_access_token')
      expect(client.access_token_secret).to eq('expected_access_secret')
    end
  end

  describe '#run' do
    context 'with no twitter_ids' do
      before { monitor.run }

      it 'starts a monitor thread' do
        expect(monitor.monitor_thread).not_to be_nil
      end

      it 'does not start a stream thread' do
        expect(monitor.tweet_consumer).to be_nil
      end

      it 'is alive' do
        expect(monitor).to be_alive
      end
    end

    context 'with twitter_ids' do
      before do
        twitter_ids = [1, 2, 3]
        monitor.run
        sleep(0.01)
      end

      it 'starts a monitor thread' do
        expect(monitor.monitor_thread).not_to be_nil
      end

      it 'starts a stream thread' do
        expect(monitor.tweet_consumer).not_to be_nil
      end

      it 'is alive' do
        expect(monitor).to be_alive
      end
    end

    context 'when the twitter_ids change' do
      before do
        twitter_ids = [1, 2, 3]
        monitor.run
        sleep(0.01)
      end

      it 'starts a new stream consumer' do
        original_consumer = monitor.tweet_consumer
        twitter_ids = [1, 2]
        sleep(0.01)

        expect(monitor.tweet_consumer).not_to be_nil
        expect(monitor.tweet_consumer).not_to eq(original_consumer)
      end
    end
  end

  describe '#stop' do
    context 'when nothing is running' do
      before { monitor.stop }

      it 'stops the  monitor thread' do
        expect(monitor.monitor_thread).to be_nil
      end

      it 'stops the tweet stream thread' do
        expect(monitor.tweet_consumer).to be_nil
      end
    end

    context 'when the monitor thread is running' do
      before do
        monitor.run
        monitor.stop
      end

      it 'stops the monitor thread' do
        expect(monitor.monitor_thread).to be_nil
      end

      it 'stops the stream thread' do
        expect(monitor.tweet_consumer).to be_nil
      end
    end
  end
end
