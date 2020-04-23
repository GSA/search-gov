require 'spec_helper'

describe WatcherNoResultsQuery do
  let(:query_args) do
    {
      affiliate_name: 'affiliate_name',
      time_window: '1w',
      min_doc_count: 50,
      query_blocklist: 'foo, bar, baz biz',
      size: 10
    }
  end
  let(:query) { WatcherNoResultsQuery.new(query_args) }
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
                  "gte": "{{ctx.trigger.scheduled_time}}||-1w",
                  "lte": "{{ctx.trigger.scheduled_time}}"
                }
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
            },
            {
              "terms": {
                "params.query.raw": [
                  "foo",
                  "bar",
                  "baz biz"
                ]
              }
            }
          ]
        }
      },
      "aggs": {
        "agg": {
          "terms": {
            "min_doc_count": 50,
            "size": 10,
            "field": "params.query.raw"
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a watcher query'
end
