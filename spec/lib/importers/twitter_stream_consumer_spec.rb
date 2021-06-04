# frozen_string_literal: true

RSpec.describe TwitterStreamConsumer do
  subject(:consumer) { described_class.new(twitter_ids) }

  let(:twitter_ids) { [] }

  describe '#follow' do
    before { consumer.follow }

    context 'when there are no live twitter ids' do
      it 'does not start the consumer thread' do
        expect(consumer.consumer_thread).to be_nil
      end
    end

    context 'when there are live twitter ids' do
      let(:twitter_ids) { [1, 2, 3] }

      it 'starts the consumer thread' do
        expect(consumer.consumer_thread).not_to be_nil
      end
    end
  end

  describe '#stop' do
    let(:twitter_ids) { [8, 6, 7] }
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
