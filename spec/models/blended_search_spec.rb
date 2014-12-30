require 'spec_helper'

describe BlendedSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe '#run' do
    context 'when search engine response contains spelling suggestion' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'electro coagulation'
      end

      before do
        suggestion = mock('suggestion', text:'electrocoagulation')
        ElasticBlended.should_receive(:search_for).
          with(hash_including(q: 'electro coagulation')).
          and_return(mock(ElasticBlendedResults,
                          results: [],
                          suggestion: suggestion,
                          total: 0))

        elastic_results = mock(ElasticBlendedResults,
                               results: [NewsItem.new],
                               suggestion: mock('suggestion', text:'electrocoagulation'),
                               total: 1)
        elastic_results.should_receive(:override_suggestion).with(suggestion)
        ElasticBlended.should_receive(:search_for).
          with(hash_including(q: 'electrocoagulation')).
          and_return(elastic_results)
      end

      it_should_behave_like 'a search with spelling suggestion'
    end
  end

  context 'when sort_by=date' do
    it 'searches for results sorted by published_at:desc' do
      ElasticBlended.should_receive(:search_for).
        with(hash_including(sort: 'published_at:desc')).
        and_return(mock(ElasticBlendedResults,
                        results: [],
                        suggestion: nil,
                        total: 0))

      BlendedSearch.new(affiliate: affiliate,
                        highlighting: false,
                        limit: 8,
                        next_offset_within_limit: true,
                        offset: 5,
                        query: 'gov',
                        sort_by: 'date').run
    end
  end
end
