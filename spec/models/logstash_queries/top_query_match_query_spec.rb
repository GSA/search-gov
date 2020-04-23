require 'spec_helper'

describe TopQueryMatchQuery do
  let(:query) do
    TopQueryMatchQuery.new('affiliate_name',
                           'my query term',
                           Date.parse("2014-06-28"),
                           Date.parse("2014-06-29"),
                           { field: 'params.query.raw', size: 1000 })
  end
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "match": {
                "params.query": {
                  "query": "my query term",
                  "analyzer": "snowball",
                  "operator": "and"
                }
              }
            },
            {
              "term": {
                "params.affiliate": "affiliate_name"
              }
            },
            {
              "terms": {
                "type": ["search","click"]
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": "2014-06-28",
                  "lte": "2014-06-29"
                }
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
          },
          "aggs": {
            "type": {
              "terms": {
                "field": "type"
              }
            }
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
