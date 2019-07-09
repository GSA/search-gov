require 'spec_helper'

describe BlendedSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  def filterable_search_options
    { affiliate: affiliate,
      enable_highlighting: true,
      limit: 20,
      offset: 0,
      query: 'electro coagulation' }
  end

  describe '#initialize' do
    pending('Does not work with Rails 5') do
      it_behaves_like 'an initialized filterable search'
    end

    context 'when options does not include sort_by' do
      subject(:search) { described_class.new filterable_search_options }
      its(:sort_by_relevance?) { should be true }
      its(:sort) { should be_nil }
    end
  end

  describe '#run' do
    pending('Does not work with Rails 5') do
      it_behaves_like 'a runnable filterable search'
    end

    context 'when search engine response contains spelling suggestion' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            limit: 20,
                            offset: 0,
                            query: 'electro coagulation'
      end

      before do
        suggestion = double('suggestion', text:'electrocoagulation')
        expect(ElasticBlended).to receive(:search_for).
          with(hash_including(q: 'electro coagulation')).
          and_return(double(ElasticBlendedResults,
                          results: [],
                          suggestion: suggestion,
                          total: 0))

        elastic_results = double(ElasticBlendedResults,
                               results: [NewsItem.new],
                               suggestion: double('suggestion', text:'electrocoagulation'),
                               total: 1)
        expect(elastic_results).to receive(:override_suggestion).with(suggestion)
        expect(ElasticBlended).to receive(:search_for).
          with(hash_including(q: 'electrocoagulation')).
          and_return(elastic_results)
      end

      it_should_behave_like 'a search with spelling suggestion'
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
