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
  end
end
