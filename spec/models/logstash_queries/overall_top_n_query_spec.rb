require 'spec_helper'

describe OverallTopNQuery do
  let(:query) do
    OverallTopNQuery.new(Date.parse('2014-06-28'),
                         { field: 'params.query.raw', size: 1234 })
  end
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "must_not": {
            "term": {
              "tags": "api"
            }
          },
          "filter": {
            "range": {
              "@timestamp": {
                "gte": "2014-06-28"
              }
            }
          }
        }
      },
      "aggs": {
        "agg": {
          "terms": {
            "field": "params.query.raw",
            "size": 1234
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
