require 'spec_helper'

describe LowCtrQuery do
  let(:query) do
    described_class.new('affiliate_name',
                    Date.new(2019,11,1),
                    Date.new(2019,11,18),
                    field: 'params.query.raw')
  end
  let(:reduce_script) do
    <<~SCRIPT.strip
      int clicks = 0;
      int searches = 0;
      for (agg in states){
        clicks += agg.click ;
        searches += agg.search
      }
      double ctr = searches == 0 ? 0 : 100.0 * clicks / searches; ctr
    SCRIPT
  end
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "term": {
                "params.affiliate": 'affiliate_name'
              }
            },
            {
              "terms": {
                "type": ['search','click']
              }
            },
            {
              "exists": {
                "field": 'modules'
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": '2019-11-01',
                  "lte": '2019-11-18'
                }
              }
            }
          ],
          "must_not": [
            {
              "term": {
                "useragent.device": 'Spider'
              }
            },
            {
              "term": {
                "params.query.raw": ''
              }
            },
            {
              "term": {
                "modules": 'QRTD'
              }
            }
          ]
        }
      },
     "aggs": {
        "agg": {
          "terms": {
            "min_doc_count": 20,
            "size": 100_000,
            "field": 'params.query.raw'
          },
          "aggs": {
            "ctr": {
              "scripted_metric": {
                "init_script": {
                  "source": "state['click'] = state['search'] = 0"
                },
                "map_script": {
                  "source": "state[doc['type'].value] += 1"
                },
                "reduce_script": {
                  "source": reduce_script
                },
                "combine_script": "return state"
              }
            }
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
