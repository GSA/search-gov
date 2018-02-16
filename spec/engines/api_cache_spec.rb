require 'spec_helper'

describe ApiCache do
  let(:cache_store) { double(ActiveSupport::Cache::FileStore) }
  let(:endpoint) { '/search.json' }
  let(:params) { { query: 'gov' } }
  let(:response) do
    body_str = Rails.root.join('spec/fixtures/json/google/web_search/ira.json').read
    Faraday::Response.new(Hashie::Mash::Rash.new(status: 200, body: body_str))
  end

  before do
    expect(ActiveSupport::Cache::FileStore).to receive(:new).and_return(cache_store)
  end

  subject(:cache) { ApiCache.new('my_api', cache_duration) }
  let(:cache_duration) { 600 }

  describe '#read', vcr: { record: :skip } do
    describe 'on cache store hit' do
      before do
        expect(cache_store).to receive(:read).with('/search.json?query=gov').and_return(response)
      end

      it 'parses response body and convert it Hashie::Mash::Rash' do
        cached_response = cache.read(endpoint, params)
        expect(cached_response.body).to be_an_instance_of(Hashie::Mash::Rash)
        expect(cached_response.body.queries).to be_present
      end
    end
  end

  describe '#write', vcr: { record: :skip } do
    it 'writes to the cache store' do
      expect(cache_store).to receive(:write).with('/search.json?query=gov', response)
      cache.write(endpoint, params, response)
    end

    context 'when the cache duration is 0' do
      let(:cache_duration) { 0 }

      it 'does not write to the cache store' do
        expect(cache_store).not_to receive(:write).with('/search.json?query=gov', response)
        cache.write(endpoint, params, response)
      end
    end
  end
end
