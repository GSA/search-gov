require 'spec_helper'

describe TopNMissingQuery do
  let(:query) { TopNMissingQuery.new('affiliate_name', { field: 'raw', size: 1000 }) }
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "must": [
            {
              "term": {
                "params.affiliate": "affiliate_name"
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
                "raw": ""
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
            "field": "raw",
            "size": 1000
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
