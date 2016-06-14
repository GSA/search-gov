require 'spec_helper'

describe RateLimitedSearchApiConnection do
  let(:cache) { mock(ApiCache, namespace: 'some_cache') }
  let(:rate_limiter) { mock(ApiRateLimiter) }
  let(:connection) { RateLimitedSearchApiConnection.new('my_api', 'http://localhost', 1000) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) { mock('response', status: 200 )}

  before do
    ApiCache.should_receive(:new).with('my_api', 1000).and_return(cache)
    ApiRateLimiter.should_receive(:new).with('my_api', false).and_return(rate_limiter)
  end

  describe '#get', vcr: { record: :skip } do
    context 'on cache hit' do
      before do
        cache.should_receive(:read).with(endpoint, params).and_return(response)
      end

      specify { connection.get(endpoint, params).should eq(CachedSearchApiConnectionResponse.new(response, 'some_cache')) }
    end

    context 'on cache miss and limit has not been reached' do
      before do
        cache.should_receive(:read).with(endpoint, params).and_return(nil)
        rate_limiter.should_receive(:within_limit).and_yield
      end

      it 'sends outbound request and cache response' do
        connection.connection.should_receive(:get).with(endpoint, params).and_return(response)
        cache.should_receive(:write).with(endpoint, params, response)

        connection.get(endpoint, params).should eq(CachedSearchApiConnectionResponse.new(response, 'none'))
      end
    end

    context 'on cache miss and limit has been reached' do
      before do
        cache.should_receive(:read).with(endpoint, params).and_return(nil)
        rate_limiter.should_receive(:within_limit)
      end

      it 'returns nil' do
        connection.connection.should_not_receive(:get)

        connection.get(endpoint, params).should eq(CachedSearchApiConnectionResponse.new(nil, 'none'))
      end
    end
  end
end
