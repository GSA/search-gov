require 'spec_helper'

describe DateRangeTopNMissingQuery do
  let(:query) do
    DateRangeTopNMissingQuery.new('affiliate_name',
                                  'search',
                                  Date.new(2015, 6, 1),
                                  Date.new(2015, 6, 30),
                                  { field: 'params.query.raw', size: 1000 })
  end
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "term": {
                "params.affiliate": "affiliate_name"
              }
            },
            {
              "terms": {
                "type": ["search"]
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": "2015-06-01",
                  "lte": "2015-06-30"
                }
              }
            }
          ],
          "must_not": [
            {
              "term": {
                "useragent.device": "Spider"
              }
            },
            {
              "term": {
                "params.query.raw": ""
              }
            },
            {
              "exists": {
                "field": "modules"
              }
            }
          ]
        }
      },
      "aggs": {
        "agg": {
          "terms": {
            "field": "params.query.raw",
            "size": 1000
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
