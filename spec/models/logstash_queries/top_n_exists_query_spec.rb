require 'spec_helper'

describe TopNExistsQuery do
  let(:query) { TopNExistsQuery.new('affiliate_name', { field: 'type', size: 1000 }) }
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
