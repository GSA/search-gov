require 'spec_helper'

describe TrendingTermsQuery do
  let(:query) { described_class.new('affiliate_name', '5h', 22) }
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "term": {
                "params.affiliate": 'affiliate_name'
              }
            },
            {
              "term": {
                "type": 'search'
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": 'now-5h/h'
                }
              }
            }
          ],
          "must_not": [
            {
              "term": {
                "useragent.device": 'Spider'
              }
            },
            {
              "term": {
                "params.query.raw": ''
              }
            },
            {
              "exists": {
                "field": 'params.page'
              }
            }
          ]
        }
      },
      "aggs": {
        "agg": {
          "significant_terms": {
            "min_doc_count": 22,
            "field": 'params.query.raw',
            "background_filter": {
              "bool": {
                "filter": [
                  {
                    "term": {
                      "params.affiliate": 'affiliate_name'
                    }
                  },
                  {
                    "term": {
                      "type": 'search'
                    }
                  }
                ],
                "must_not": [
                  {
                    "term": {
                      "useragent.device": 'Spider'
                    }
                  },
                  {
                    "term": {
                      "params.query.raw": ''
                    }
                  },
                  {
                    "exists": {
                      "field": 'params.page'
                    }
                  }
                ]
              }
            }
          },
          "aggs": {
            "clientip_count": {
              "cardinality": {
                "field": 'clientip'
              }
            }
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
