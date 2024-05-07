# frozen_string_literal: true

describe CachedSearchApiConnection do
  let(:cached_connection) { described_class.new('my_api', 'http://localhost', 1000) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) { double('response', status: 200 ) }

  describe '#connection' do
    subject(:connection) { cached_connection.connection }

    it 'uses the desired handlers in the expected order' do
      expect(connection.builder.handlers).to eq(
        [
          FaradayMiddleware::EncodeJson,
          FaradayMiddleware::ExceptionNotifier,
          Faraday::Response::RaiseError,
          FaradayMiddleware::Rashify,
          FaradayMiddleware::ParseJson,
          Faraday::Adapter::NetHttpPersistent
        ]
      )
    end
  end

  describe '#basic_auth' do
    it 'delegates to @connection instance variable' do
      expect(cached_connection.connection).to receive(:basic_auth).with('user', 'pass')
      cached_connection.basic_auth 'user', 'pass'
    end
  end

  describe '#get' do
    context 'when response has not been cached' do
      it 'calls the api' do
        expect(cached_connection.connection).to receive(:get).with(endpoint, params)

        cached_connection.get(endpoint, params)
      end
    end

    context 'when response has been cached' do
      it 'calls the api' do
        allow(Rails.cache).to receive(:fetch).and_return(response)

        expect(cached_connection.get(endpoint, params)).to eq response
      end
    end
  end
end
