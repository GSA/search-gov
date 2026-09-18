# frozen_string_literal: true

require 'spec_helper'

describe OpenSearch::DocumentSearch do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_options) do
    {
      indices: ['test_index'],
      query: 'electro coagulation',
      size: 10,
      offset: 0
    }
  end

  describe '#search' do
    let(:search) { described_class.new(search_options, affiliate: affiliate) }
    let(:search_results) do
      {
        'hits' => {
          'total' => 100,
          'hits' => []
        }
      }
    end

    before do
      allow(OPENSEARCH_CLIENT).to receive(:search).and_return(search_results)
    end

    it 'returns an OpenSearch::DocumentSearchResults object' do
      expect(search.search).to be_a(OpenSearch::DocumentSearchResults)
    end

    it 'calls the search client with the correct arguments' do
      search.search
      expect(OPENSEARCH_CLIENT).to have_received(:search).with(
        index: ['test_index'],
        body: anything,
        from: 0,
        size: 10,
        rest_total_hits_as_int: true
      )
    end

    describe 'query result caching' do
      let(:cache) { ActiveSupport::Cache::MemoryStore.new }

      before do
        allow(Rails).to receive(:cache).and_return(cache)
      end

      def search_with(options = search_options)
        described_class.new(options, affiliate: affiliate)
      end

      it 'queries OpenSearch on a miss and serves the cache on a hit' do
        first = search_with
        second = search_with
        first.search
        second.search

        expect(OPENSEARCH_CLIENT).to have_received(:search).once
        expect(first.from_cache).to be(false)
        expect(second.from_cache).to be(true)
      end

      it 'treats differently cased queries as the same cache key' do
        search_with(search_options.merge(query: 'Electro Coagulation')).search
        search_with(search_options.merge(query: 'electro coagulation')).search

        expect(OPENSEARCH_CLIENT).to have_received(:search).once
      end

      it 'does not reuse a page-1 entry for a different offset' do
        search_with.search
        search_with(search_options.merge(offset: 20)).search

        expect(OPENSEARCH_CLIENT).to have_received(:search).twice
      end

      it "does not reuse another affiliate's entry" do
        search_with.search
        described_class.new(search_options, affiliate: affiliates(:another_affiliate)).search

        expect(OPENSEARCH_CLIENT).to have_received(:search).twice
      end

      it 'does not write when skip_cache is true' do
        search_with(search_options.merge(skip_cache: true)).search
        search_with.search

        expect(OPENSEARCH_CLIENT).to have_received(:search).twice
      end

      it 'skips the cache when OPENSEARCH_CACHE_DURATION is 0' do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('OPENSEARCH_CACHE_DURATION', '15').and_return('0')

        search_with.search
        search_with.search

        expect(OPENSEARCH_CLIENT).to have_received(:search).twice
      end

      it 'does not cache a raised client error' do
        allow(OPENSEARCH_CLIENT).to receive(:search).and_raise(StandardError, 'boom')

        expect { search_with.search }.to raise_error(StandardError, 'boom')

        allow(OPENSEARCH_CLIENT).to receive(:search).and_return(search_results)
        search_with.search

        expect(OPENSEARCH_CLIENT).to have_received(:search).twice
      end
    end

    context 'when a result title is a percent-encoded filename' do
      let(:search_results) do
        {
          'hits' => {
            'total' => 1,
            'hits' => [
              { '_source' => { 'path' => 'https://www.va.gov/files/2022-10/BA%20degree%20nurse%20scholarship_0.pdf',
                               'language' => 'en',
                               'title_en' => 'BA%20degree%20nurse%20scholarship_0.pdf' } }
            ]
          }
        }
      end

      it 'decodes the title for downstream SERP and API consumers' do
        expect(search.search.results.first['title']).to eq('BA degree nurse scholarship_0.pdf')
      end
    end
  end
end
