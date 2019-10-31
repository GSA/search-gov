require 'spec_helper'

describe ElasticLinkPopularityQuery do
  let(:query) { ElasticLinkPopularityQuery.new('https://search.gov', 10) }

  describe '#body' do
    subject(:body) { query.body }

    let(:expected_body) do
      {
        query: {
          constant_score: {
            filter: {
              bool: {
                must: [
                  {
                    terms: {
                      'params.url': [
                        'https://search.gov',
                        'https://search.gov/'
                      ]
                    }
                  },
                  {
                    range: {
                      '@timestamp': {
                        gt: 'now-10d/d'
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }.to_json
    end

    it { is_expected.to eq(expected_body) }
  end
end
