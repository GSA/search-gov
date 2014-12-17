require 'spec_helper'

describe BlendedSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

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
