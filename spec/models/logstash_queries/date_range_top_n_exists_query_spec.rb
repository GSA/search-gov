require 'spec_helper'

describe DateRangeTopNExistsQuery do
  let(:query) do
    DateRangeTopNExistsQuery.new('affiliate_name',
                                 'search',
                                 Date.new(2019, 11, 1),
                                 Date.new(2019, 11, 7),
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
              "exists": {
                "field": "modules"
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": "2019-11-01",
                  "lte": "2019-11-07"
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
              "term": {
                "modules": "QRTD"
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
