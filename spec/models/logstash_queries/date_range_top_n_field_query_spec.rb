require 'spec_helper'

describe DateRangeTopNFieldQuery do
  let(:query) do
    DateRangeTopNFieldQuery.new('affiliate_name',
                                Date.parse('2014-06-28'),
                                Date.parse('2014-06-29'),
                                'params.url',
                                'some_url',
                                { field: 'params.query.raw', size: 100 })
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
              "term": {
                "params.url": "some_url"
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
          ]
        }
      },
      "aggs": {
        "agg": {
          "terms": {
            "field": "params.query.raw",
            "size": 100
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'

  context 'when the affiliate is nil' do
    let(:query) do
      DateRangeTopNFieldQuery.new(nil,
                                  Date.parse("2014-06-28"),
                                  Date.parse("2014-06-29"),
                                  'params.url',
                                  'some_url',
                                  { field: 'params.query.raw', size: 100 })
    end
    let(:expected_body) do
      {
        "query": {
          "bool": {
            "filter": [
              {
                "term": {
                  "params.url": "some_url"
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
            ]
          }
        },
        "aggs": {
          "agg": {
            "terms": {
              "field": "params.query.raw",
              "size": 100
            }
          }
        }
      }.to_json
    end

    it_behaves_like 'a logstash query'
  end
end
