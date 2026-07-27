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

      it 'decodes the percent-encoding and strips the extension' do
        expect(results.first['title']).to eq('BA degree nurse scholarship_0')
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

      it 'discards the query string, decodes the filename, and strips the extension' do
        expect(results.first['title']).to eq('59702 Waterman Steamship Corporation 3.12.15')
      end
    end

    context 'when the filename title has no extension' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://www.oig.dol.gov/public/Press%20Releases/foo.pdf',
                         'language' => 'en',
                         'title_en' => 'AZ*AG*Attorney%20General%20Kris%20Mayes%20Announces%20Sentencing%20in%20Pandemic%20Unemployment%20Assistance%20Fraud' } }
      end

      it 'still decodes the percent-encoding' do
        expect(results.first['title']).to eq('AZ*AG*Attorney General Kris Mayes Announces Sentencing in Pandemic Unemployment Assistance Fraud')
      end
    end

    context 'when the title is a normal metadata title' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://search.gov/about/',
                         'language' => 'en',
                         'title_en' => 'About Search.gov | Search.gov' } }
      end

      it 'leaves the title unchanged' do
        expect(results.first['title']).to eq('About Search.gov | Search.gov')
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

    context 'when the title is highlighted' do
      let(:result) do
        { 'hits' => { 'total' => 1, 'hits' => [hits] },
          'aggregations' => {},
          'suggest' => [] }
      end
      let(:hits) do
        { '_type' => '_doc',
          '_source' => { 'path' => 'https://search.gov/about/',
                         'language' => 'en',
                         'title_en' => 'About Search.gov | Search.gov' },
          'highlight' => { 'title_en' => ["About \uE000Search\uE001.gov | Search.gov"] } }
      end

      it 'preserves highlight markers' do
        expect(results.first['title']).to eq("About \uE000Search\uE001.gov | Search.gov")
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
