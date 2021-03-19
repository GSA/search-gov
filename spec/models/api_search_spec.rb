require 'spec_helper'

describe ApiSearch do
  fixtures :affiliates

  describe '.search' do
    context 'format is json' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { described_class.redis }
      let(:format) { 'json' }
      let(:params) { {query: 'foobar', page: 2, per_page: 10, affiliate: affiliate, format: format} }
      let(:search) { double(WebSearch, diagnostics: { 'AWEB' => :underlying_search_diagnostics }) }
      let(:search_result_in_json) { '{"results":["foo","bar","baz"]}' }

      before :each do
        expect(WebSearch).to receive(:new).with(params).and_return(search)
        expect(search).to receive(:cache_key).and_return('search_cache_key')
        @api_cache_key = ['API', 'WebSearch', 'search_cache_key', format.to_s].join(':')
        allow(Time).to receive(:now).and_return(42, 44)
      end

      context 'when api search cache miss' do
        it 'should run search and cache the result' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_return(nil)
          expect(search).to receive(:run)
          expect(search).to receive(:to_json).and_return(search_result_in_json)
          expect(api_redis).to receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_json)
          expect(api_search.diagnostics).to eq({
            'APIV1' => {
              result_count: 3,
              from_cache: 'none',
              elapsed_time_ms: 2000
            },
            'AWEB' => :underlying_search_diagnostics
          })
        end
      end

      context 'when api search cache hit' do
        it 'should not run search' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_return(search_result_in_json)
          expect(api_redis).not_to receive(:setex)
          expect(search).not_to receive(:run)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_json)
          expect(api_search.diagnostics).to eq({
            'APIV1' => {
              result_count: 3,
              from_cache: 'api_v1_redis',
              elapsed_time_ms: 2000
            }
          })
        end
      end

      context 'when retrieving from cache raises Error' do
        it 'should run search and cache the result' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_raise(StandardError)
          expect(search).to receive(:run)
          expect(search).to receive(:to_json).and_return(search_result_in_json)
          expect(api_redis).to receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_json)
        end
      end

      context 'when caching result raises Error' do
        it 'should run search and cache the result' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_return(nil)
          expect(search).to receive(:run)
          expect(search).to receive(:to_json).and_return(search_result_in_json)
          expect(api_redis).to receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json).and_raise(StandardError)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_json)
        end
      end
    end

    context 'when format is xml' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { described_class.redis }
      let(:format) { 'xml' }
      let(:params) { {query: 'foobar', page: 2, per_page: 10, affiliate: affiliate, format: format} }
      let(:search) { double(WebSearch, diagnostics: {}) }
      let(:search_result_in_xml) { double('search_result_in_xml') }

      before :each do
        expect(WebSearch).to receive(:new).with(params).and_return(search)
        expect(search).to receive(:cache_key).and_return('search_cache_key')
        @api_cache_key = ['API', 'WebSearch', 'search_cache_key', format.to_s].join(':')
      end

      context 'when api search has a cache miss' do
        it 'should run search and cache the result' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_return(nil)
          expect(search).to receive(:run)
          expect(search).to receive(:to_xml).and_return(search_result_in_xml)
          expect(api_redis).to receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_xml)
        end
      end

      context 'when api search cache hit' do
        it 'should not run search' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_return(search_result_in_xml)
          expect(api_redis).not_to receive(:setex)
          expect(search).not_to receive(:run)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_xml)
        end
      end

      context 'when retrieving from cache raises Error' do
        it 'should run search and cache the result' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_raise(StandardError)
          expect(search).to receive(:run)
          expect(search).to receive(:to_xml).and_return(search_result_in_xml)
          expect(api_redis).to receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_xml)
        end
      end

      context 'when caching result raises Error' do
        it 'should run search and cache the result' do
          expect(api_redis).to receive(:get).with(@api_cache_key).and_return(nil)
          expect(search).to receive(:run)
          expect(search).to receive(:to_xml).and_return(search_result_in_xml)
          expect(api_redis).to receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml).and_raise(StandardError)
          api_search = described_class.new(params)
          expect(api_search.run).to eq(search_result_in_xml)
        end
      end
    end

    describe 'handling of source index' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { described_class.redis }
      let(:format) { 'json' }
      let(:params) { {query: 'foobar', page: 1, per_page: 10, affiliate: affiliate, format: format} }
      let(:search) { double(WebSearch) }

      before do
        allow(search).to receive(:cache_key).and_return('search_cache_key')
        allow(search).to receive(:run)
        allow(search).to receive(:to_json).and_return 'search_result_in_json'
      end

      context "when it's web" do
        it 'should create a WebSearch object' do
          expect(WebSearch).to receive(:new).with(params.merge(index: 'web')).and_return(search)
          described_class.new(params.merge(index: 'web'))
        end
      end

      context "when it's undefined" do
        it 'should create a WebSearch object' do
          expect(WebSearch).to receive(:new).with(params).and_return(search)
          described_class.new(params)
        end
      end

      context "when it's news" do
        it 'should create a NewsSearch object' do
          expect(ApiNewsSearch).to receive(:new).with(params.merge(index: 'news')).and_return(search)
          described_class.new(params.merge(index: 'news'))
        end
      end

      context "when it's videonews" do
        it 'should create a VideoNewsSearch object' do
          expect(VideoNewsSearch).to receive(:new).with(params.merge(index: 'videonews')).and_return(search)
          described_class.new(params.merge(index: 'videonews'))
        end
      end

      context "when it's images" do
        it 'should create an ApiLegacyImageSearch object' do
          expect(ApiLegacyImageSearch).to receive(:new).with(params.merge(index: 'images')).and_return(search)
          described_class.new(params.merge(index: 'images'))
        end
      end

      context "when it's document collections (docs)" do
        it 'should create a SiteSearch object' do
          expect(SiteSearch).to receive(:new).with(params.merge(index: 'docs', dc: '45')).and_return(search)
          described_class.new(params.merge(index: 'docs', dc: '45'))
        end
      end
    end

  end
end
