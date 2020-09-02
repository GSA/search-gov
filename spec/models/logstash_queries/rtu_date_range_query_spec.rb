require 'spec_helper'

describe RtuDateRangeQuery do
  let(:query) { RtuDateRangeQuery.new('affiliate_name', 'search') }
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
          "must_not": {
            "term": {
              "useragent.device": "Spider"
            }
          }
        }
      },
      "aggs": {
        "stats": {
          "stats": {
            "field": "@timestamp"
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
