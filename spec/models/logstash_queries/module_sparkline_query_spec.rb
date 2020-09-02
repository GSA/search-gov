require 'spec_helper'

describe ModuleSparklineQuery do
  let(:query) { ModuleSparklineQuery.new('affiliate_name') }
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
                "type": ["search","click"]
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": "now-60d/d"
                }
              }
            },
            {
              "exists": {
                "field": "modules"
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
            "field": "modules",
            "size": 100
          },
          "aggs": {
            "histogram": {
              "date_histogram": {
                "field": "@timestamp",
                "interval": "day",
                "format": "yyyy-MM-dd",
                "min_doc_count": 0
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
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
