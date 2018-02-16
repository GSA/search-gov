require 'spec_helper'

describe RateLimitedSearchApiConnection do
  let(:cache) { double(ApiCache, namespace: 'some_cache') }
  let(:rate_limiter) { double(ApiRateLimiter) }
  let(:connection) { RateLimitedSearchApiConnection.new('my_api', 'http://localhost', 1000) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) { double('response', status: 200 )}

  before do
    expect(ApiCache).to receive(:new).with('my_api', 1000).and_return(cache)
    expect(ApiRateLimiter).to receive(:new).with('my_api', false).and_return(rate_limiter)
  end

  describe '#get', vcr: { record: :skip } do
    context 'on cache hit' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(response)
      end

      specify { expect(connection.get(endpoint, params)).to eq(CachedSearchApiConnectionResponse.new(response, 'some_cache')) }
    end

    context 'on cache miss and limit has not been reached' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(nil)
        expect(rate_limiter).to receive(:within_limit).and_yield
      end

      it 'sends outbound request and cache response' do
        expect(connection.connection).to receive(:get).with(endpoint, params).and_return(response)
        expect(cache).to receive(:write).with(endpoint, params, response)

        expect(connection.get(endpoint, params)).to eq(CachedSearchApiConnectionResponse.new(response, 'none'))
      end
    end

    context 'on cache miss and limit has been reached' do
      before do
        expect(cache).to receive(:read).with(endpoint, params).and_return(nil)
        expect(rate_limiter).to receive(:within_limit)
      end

      it 'returns nil' do
        expect(connection.connection).not_to receive(:get)

        expect(connection.get(endpoint, params)).to eq(CachedSearchApiConnectionResponse.new(nil, 'none'))
      end
    end
  end
end
