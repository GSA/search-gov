require 'spec_helper'

describe CountQuery do
  let(:query) { CountQuery.new('affiliate_name', 'click') }
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
