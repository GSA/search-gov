require 'spec_helper'

describe CachedSearchApiConnection do
  let(:cache) { mock(ApiCache, namespace: 'some_cache') }
  let(:connection) { described_class.new('my_api', 'http://localhost', 1000) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) { mock('response', status: 200 )}

  before do
    ApiCache.should_receive(:new).with('my_api', 1000).and_return(cache)
  end

  describe '#basic_auth' do
    it 'delegates to @connection instance variable' do
      connection.connection.should_receive(:basic_auth).with('user', 'pass')
      connection.basic_auth 'user', 'pass'
    end
  end

  describe '#get', vcr: { record: :skip } do
    context 'on cache hit' do
      before do
        cache.should_receive(:read).with(endpoint, params).and_return(response)
      end

      specify { connection.get(endpoint, params).should eq(CachedSearchApiConnectionResponse.new(response, 'some_cache')) }
    end

    context 'on cache miss' do
      before do
        cache.should_receive(:read).with(endpoint, params).and_return(nil)
      end

      it 'sends outbound request and cache response' do
        connection.connection.should_receive(:get).with(endpoint, params).and_return(response)
        cache.should_receive(:write).with(endpoint, params, response)

        connection.get(endpoint, params).should eq(CachedSearchApiConnectionResponse.new(response, 'none'))
      end
    end
  end
end
