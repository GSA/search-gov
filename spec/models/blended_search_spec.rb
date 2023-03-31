# frozen_string_literal: true

require 'spec_helper'

describe BlendedSearch do
  let(:affiliate) { affiliates(:usagov_affiliate) }

  let(:filterable_search_options) do
    { affiliate: affiliate,
      enable_highlighting: true,
      limit: 20,
      offset: 0,
      query: 'electro coagulation' }
  end

  describe '#initialize' do
    it_behaves_like 'an initialized filterable search'

    context 'when options does not include sort_by' do
      subject(:search) { described_class.new filterable_search_options }

      its(:sort_by_relevance?) { is_expected.to be true }
      its(:sort) { is_expected.to be_nil }
    end

    # NOTE: While this confirms that these params are passed on to BlendedSearch by FilterableSearch, but, at present,
    # BlendedSearch does not do anything with these params.
    context 'when facet filters are present' do
      subject(:test_search) do
        described_class.new filterable_search_options.
          merge(tags: 'tag from params')
      end

      its(:tags) { is_expected.to eq('tag from params') }
    end
  end

  describe '#normalized_results' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          enable_highlighting: true,
                          limit: 20,
                          offset: 0,
                          query: 'electro coagulation'
    end

    before do
      elastic_results = instance_double(ElasticBlendedResults,
                                        results: [IndexedDocument.new(title: 'electro coagulation', description: 'electro coagulation', url: 'http://p.whitehouse.gov/hour.html', last_crawl_status: 'OK', affiliate: affiliates(:usagov_affiliate))],
                                        suggestion: double('suggestion', text: 'electro coagulation'),
                                        total: 1)
      allow(elastic_results).to receive(:override_suggestion)
      allow(ElasticBlended).to receive(:search_for).
        with(hash_including(q: 'electro coagulation')).
        and_return(elastic_results)
    end

    it 'returns normalized results for the SERP redesign' do
      search.run
      expect(search.normalized_results).to eq([{ title: 'electro coagulation', url: 'http://p.whitehouse.gov/hour.html', description: 'electro coagulation' }])
    end
  end

  describe '#run' do
    it_behaves_like 'a runnable filterable search'

    context 'when search engine response contains spelling suggestion' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            limit: 20,
                            offset: 0,
                            query: 'electro coagulation'
      end

      before do
        suggestion = double('suggestion', text: 'electrocoagulation')
        expect(ElasticBlended).to receive(:search_for).
          with(hash_including(q: 'electro coagulation')).
          and_return(double(ElasticBlendedResults,
                            results: [],
                            suggestion: suggestion,
                            total: 0))

        elastic_results = double(ElasticBlendedResults,
                                 results: [NewsItem.new],
                                 suggestion: double('suggestion', text: 'electrocoagulation'),
                                 total: 1)
        expect(elastic_results).to receive(:override_suggestion).with(suggestion)
        expect(ElasticBlended).to receive(:search_for).
          with(hash_including(q: 'electrocoagulation')).
          and_return(elastic_results)
      end

      it_behaves_like 'a search with spelling suggestion'
    end
  end

  context 'when sort_by=date' do
    it 'searches for results sorted by published_at:desc' do
      expect(ElasticBlended).to receive(:search_for).
        with(hash_including(sort: 'published_at:desc')).
        and_return(double(ElasticBlendedResults,
                          results: [],
                          suggestion: nil,
                          total: 0))

      described_class.new(affiliate: affiliate,
                          highlighting: false,
                          limit: 8,
                          next_offset_within_limit: true,
                          offset: 5,
                          query: 'gov',
                          sort_by: 'date').run
    end
  end
end
