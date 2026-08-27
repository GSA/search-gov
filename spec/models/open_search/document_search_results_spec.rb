# frozen_string_literal: true

require 'spec_helper'

describe OpenSearch::DocumentSearchResults do
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

    context 'when the title is a percent-encoded filename' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://www.va.gov/files/2022-10/BA%20degree%20nurse%20scholarship_0.pdf',
                         'language' => 'en',
                         'title_en' => 'BA%20degree%20nurse%20scholarship_0.pdf' } }
      end

      it 'decodes the percent-encoding' do
        expect(results.first['title']).to eq('BA degree nurse scholarship_0.pdf')
      end
    end

    context 'when the filename title carries a query string' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://www.asbca.mil/Portals/143/Decisions/2015/foo.pdf',
                         'language' => 'en',
                         'title_en' => '59702%20Waterman%20Steamship%20Corporation%203.12.15.pdf?ver=kx-UXd05JFKrQzcV6QQKoQ==' } }
      end

      it 'discards the query string and decodes the filename' do
        expect(results.first['title']).to eq('59702 Waterman Steamship Corporation 3.12.15.pdf')
      end
    end

    context 'when a normal title contains a percent sign with spaces' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://search.gov/report/',
                         'language' => 'en',
                         'title_en' => 'Save 20%20 on the report' } }
      end

      it 'does not decode titles that contain whitespace' do
        expect(results.first['title']).to eq('Save 20%20 on the report')
      end
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
