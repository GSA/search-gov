require 'spec_helper'

describe CachedSearchApiConnection do
  let(:cache) { double(ApiCache, namespace: 'some_cache') }
  let(:connection) { described_class.new('my_api', 'http://localhost', 1000) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) { double('response', status: 200 )}

  before do
    expect(ApiCache).to receive(:new).with('my_api', 1000).and_return(cache)
  end

  describe '#basic_auth' do
    it 'delegates to @connection instance variable' do
      expect(connection.connection).to receive(:basic_auth).with('user', 'pass')
      connection.basic_auth 'user', 'pass'
    end
  end

  describe '#get', vcr: { record: :skip } do
    context 'on cache hit' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(response)
      end

      specify { expect(connection.get(endpoint, params)).to eq(CachedSearchApiConnectionResponse.new(response, 'some_cache')) }
    end

    context 'on cache miss' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(nil)
      end

      it 'sends outbound request and cache response' do
        expect(connection.connection).to receive(:get).with(endpoint, params).and_return(response)
        expect(cache).to receive(:write).with(endpoint, params, response)

        expect(connection.get(endpoint, params)).to eq(CachedSearchApiConnectionResponse.new(response, 'none'))
      end
    end
  end
end
