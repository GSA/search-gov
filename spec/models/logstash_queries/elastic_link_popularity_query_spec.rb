require 'spec_helper'

describe ElasticLinkPopularityQuery do
  let(:query) { ElasticLinkPopularityQuery.new('https://search.gov', 10) }
  let(:expected_body) do
    {
      "query": {
        "constant_score": {
          "filter": {
            "bool": {
              "must": [
                {
                  "term": {
                    "type": "click"
                  }
                },
                {
                  "terms": {
                    "params.url": [
                      "https://search.gov",
                      "https://search.gov/"
                    ]
                  }
                },
                {
                  "range": {
                    "@timestamp": {
                      "gt": "now-10d/d"
                    }
                  }
                }
              ]
            }
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
