require 'spec_helper'

describe TopNQuery, "#body" do
  let(:query) do
    TopNQuery.new(
      'affiliate_name',
      'search',
      { field: 'params.query.raw',
        size: 1000 }
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
          "must_not": {
            "term": {
              "useragent.device": "Spider"
            }
          }
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
