require 'spec_helper'

describe ModuleBreakdownQuery do
  let(:query) { ModuleBreakdownQuery.new('affiliate_name') }
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

  context 'when the affiliate_name is missing' do
    let(:query) { ModuleBreakdownQuery.new }
    let(:expected_body) do
      {
        "query": {
          "bool": {
            "filter": [
              {
                "terms": {
                  "type": ["search","click"]
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
end
