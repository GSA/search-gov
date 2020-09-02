require 'spec_helper'

describe MonthlyHistogramQuery do
  let(:query) { MonthlyHistogramQuery.new('affiliate_name', Date.parse('2014-06-28')) }
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
              "range": {
                "@timestamp": {
                  "gte": "2014-06-28"
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
          "date_histogram": {
            "field": "@timestamp",
            "interval": "month",
            "format": "yyyy-MM",
            "min_doc_count": 0
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
