require 'spec_helper'

describe OpenSearch::Engine do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_options) do
    {
      affiliate: affiliate,
      query: 'electro coagulation'
    }
  end

  it 'is a SearchElasticEngine' do
    expect(described_class.new(search_options)).to be_a(SearchElasticEngine)
  end

  describe '#search' do
    let(:search) { described_class.new(search_options) }
    let(:search_results) do
      results = double('results',
                     results: [mock_model(NewsItem, title: 'some result')],
                     total: 100,
                     offset: 0,
                     suggestion: nil,
                     aggregations: nil)
      allow(results).to receive(:results).and_return(results.results)
      allow(results).to receive(:total).and_return(results.total)
      allow(results).to receive(:offset).and_return(results.offset)
      allow(results).to receive(:suggestion).and_return(results.suggestion)
      allow(results).to receive(:aggregations).and_return(results.aggregations)
      results
    end

    before do
      allow(OpenSearch::DocumentSearch).to receive(:new).and_return(double('document search', search: search_results))
    end

    it 'returns a hashie mash of the results' do
      expect(search.search).to be_a(Hashie::Mash::Rash)
    end
  end
end
