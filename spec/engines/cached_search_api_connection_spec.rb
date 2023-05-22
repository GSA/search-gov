# frozen_string_literal: true

describe CachedSearchApiConnection do
  let(:cache) { double(ApiCache, namespace: 'some_cache') }
  let(:cached_connection) { described_class.new('my_api', 'http://localhost', 1000) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) { double('response', status: 200 ) }

  before do
    expect(ApiCache).to receive(:new).with('my_api', 1000).and_return(cache)
  end

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

  describe '#get', vcr: { record: :skip } do
    context 'on cache hit' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(response)
      end

      specify { expect(cached_connection.get(endpoint, params)).
        to eq(CachedSearchApiConnectionResponse.new(response, 'some_cache')) }
    end

    context 'on cache miss' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(nil)
      end

      it 'sends outbound request and cache response' do
        expect(cached_connection.connection).to receive(:get).with(endpoint, params).and_return(response)
        expect(cache).to receive(:write).with(endpoint, params, response)

        expect(cached_connection.get(endpoint, params)).
          to eq(CachedSearchApiConnectionResponse.new(response, 'none'))
      end
    end
  end
end
