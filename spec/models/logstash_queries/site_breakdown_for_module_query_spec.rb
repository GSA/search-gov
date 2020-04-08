require 'spec_helper'

describe SiteBreakdownForModuleQuery do
  let(:query) { SiteBreakdownForModuleQuery.new('I14Y') }
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "term": {
                "modules": "I14Y"
              }
            },
            {
              "terms": {
                "type": ["search","click"]
              }
            },
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
            "field": "params.affiliate",
            "size": 10_000
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
