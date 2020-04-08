require 'spec_helper'

describe TopNMissingQuery do
  let(:query) do
    TopNMissingQuery.new(
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
            "field": "type",
            "size": 1000
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
