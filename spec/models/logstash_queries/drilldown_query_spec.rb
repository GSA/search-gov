require 'spec_helper'

describe DrilldownQuery do
  let(:query) do
    DrilldownQuery.new('affiliate_name',
                       Date.new(2019,11,01),
                       Date.new(2019,11,15),
                       'params.query.raw',
                       'foo',
                       'click')
  end
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "range": {
                "@timestamp": {
                  "gte": "2019-11-01",
                  "lte": "2019-11-15"
                }
              }
            },
            {
              "term": {
                "params.query.raw": "foo"
              }
            },
            {
              "term": {
                "params.affiliate": "affiliate_name"
              }
            },
            {
              "terms": {
                "type": ["click"]
              }
            }
          ],
          "must_not": {
            "term": {
              "useragent.device": "Spider"
            }
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
