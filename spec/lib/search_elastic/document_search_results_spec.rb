# frozen_string_literal: true

require 'spec_helper'

describe SearchElastic::DocumentSearchResults do
  let(:document_search_results) { described_class.new(result) }

  describe '#suggestion' do
    subject(:suggestion) { document_search_results.suggestion }

    context 'when no hits and suggestions are present' do
      let(:result) do
        { 'hits' => { 'total' => 0, 'hits' => [] },
          'aggregations' => {},
          'suggest' => suggestion_hash }
      end
      let(:suggestion_hash) do
        { 'suggestion' =>
                            [{ 'text' => 'blue',
                               'options' => [{ 'text' => 'bulk',
                                               'highlighted' => 'bulk' }] }] }
      end

      it { is_expected.to match(hash_including({ 'text' => 'bulk', 'highlighted' => 'bulk' })) }
    end
  end

  describe '#results' do
    subject(:results) { document_search_results.results }

    context 'when hits are present' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://search.gov/about/',
                         'created' => '2021-02-03T00:00:00.000-05:00',
                         'language' => 'en',
                         'title_en' => 'About Search.gov | Search.gov' },
          'highlight' => { 'content_en' => ['Some highlighted content'] } }
      end

      it {
        is_expected.to match(array_including({ 'path' => 'https://search.gov/about/',
                                               'created' => '2021-02-03 05:00:00 UTC',
                                               'language' => 'en',
                                               'title' => 'About Search.gov | Search.gov',
                                               'content' => 'Some highlighted content' }))
      }
    end
  end

  describe '#aggregations' do
    subject(:aggregations) { document_search_results.aggregations }

    context 'when aggregations are present' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => aggregations_hash,
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://search.gov/about/',
                         'created' => '2021-02-03T00:00:00.000-05:00',
                         'language' => 'en',
                         'title_en' => 'About Search.gov | Search.gov' },
          'highlight' => { 'content_en' => ['Some highlighted content'] } }
      end
      let(:aggregations_hash) do
        { 'content_type' => { 'doc_count_error_upper_bound' => 0,
                              'sum_other_doc_count' => 0,
                              'buckets' => [{ 'key' => 'article',
                                              'doc_count' => 1 }] },
          'tags' => { 'doc_count_error_upper_bound' => 0,
                      'sum_other_doc_count' => 0,
                      'buckets' => [] } }
      end

      it { is_expected.to match(array_including({ content_type: [{ agg_key: 'article', doc_count: 1 }] })) }

      it { is_expected.not_to include(hash_including(:tags)) }
    end
  end
end
