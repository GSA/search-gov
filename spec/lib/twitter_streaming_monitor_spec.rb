# frozen_string_literal: true

describe TwitterStreamingMonitor do
  subject(:monitor) { described_class.new(twitter_ids_holder) }

  twitter_ids = [] # needs to be a variable so the block in the next let works.
  let(:twitter_ids_holder) { SynchronizedObjectHolder.new { twitter_ids } }

  after { monitor.stop }

  context 'when initally created' do
    it 'does not have a monitor thread' do
      expect(monitor.monitor_thread).to be_nil
    end

    it 'does not have a stream thread' do
      expect(monitor.tweet_consumer).to be_nil
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
