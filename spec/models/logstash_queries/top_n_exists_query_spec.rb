require 'spec_helper'

describe TopNExistsQuery do
  let(:query) do
    TopNExistsQuery.new(
      'affiliate_name',
      'search',
      { field: 'type', size: 1000 }
    )
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
            "field": "type",
            "size": 1000
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
