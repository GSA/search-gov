require 'spec_helper'

describe TopNQuery, "#body" do
  let(:query) { TopNQuery.new('affiliate_name', { field: 'raw', size: 1000 }) }
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": {
            "term": {
              "params.affiliate": "affiliate_name"
            }
          },
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
            "field": "raw",
            "size": 1000
          }
        }
      }
    }.to_json
  end

  include_context 'querying logstash indexes'

  it_behaves_like 'a logstash query'
end
