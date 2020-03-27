require 'spec_helper'

describe QueryBreakdownForSiteModuleQuery do
  let(:query) { QueryBreakdownForSiteModuleQuery.new('BOOS', 'affiliate_name') }
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "terms": {
                "type": ["search","click"]
              }
            },
            {
              "term": {
                "modules": "BOOS"
              }
            },
            {
              "term": {
                "params.affiliate": "affiliate_name"
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
