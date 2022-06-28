# frozen_string_literal: true

describe ElasticBlendedQuery do
  let(:options) do
    {
      highlighting: true,
      affiliate_id: 1,
      language: 'en',
      offset: 0,
      q: 'my query',
      rss_feed_url_ids: [2, 3],
      size: 20,
      sort: nil,
      since: '2022-06-01',
      until: '2022-06-30'
    }
  end
  let(:query) { described_class.new(options) }
  let(:expected_body) do
    {
      "query": {
        "function_score": {
          "query": {
            "bool": {
              "must": [
                {
                  "query_string": {
                    "fields": [
                      "title.en",
                      "description.en",
                      "body.en"
                    ],
                    "query": "my query",
                    "analyzer": "en_analyzer",
                    "default_operator": "AND"
                  }
                }
              ],
              "filter": {
                "bool": {
                  "must": [
                    {
                      "range": {
                        "published_at": {
                          "gt": "2022-06-01",
                          "lt": "2022-06-30"
                        }
                      }
                    }
                  ],
                  "should": [
                    {
                      "term": {
                        "affiliate_id": 1
                      }
                    },
                    {
                      "terms": {
                        "rss_feed_url_id": [
                          2,
                          3
                        ]
                      }
                    }
                  ],
                  "minimum_should_match": 1
                }
              }
            }
          },
          "functions": [
            {
              "gauss": {
                "published_at": {
                  "scale": "28d"
                }
              }
            },
            {
              "field_value_factor": {
                "field": "popularity"
              }
            }
          ]
        }
      },
      "highlight": {
        "type": "fvh",
        "pre_tags": [
          ""
        ],
        "post_tags": [
          ""
        ],
        "fields": {
          "title.en": {
            "number_of_fragments": 0
          },
          "description.en": {
            "fragment_size": 75,
            "number_of_fragments": 2
          },
          "body.en": {
            "fragment_size": 75,
            "number_of_fragments": 2
          }
        }
      },
      "suggest": {
        "text": "my query",
        "suggestion": {
          "phrase": {
            "analyzer": "bigram_analyzer",
            "field": "bigram",
            "size": 1,
            "direct_generator": [
              {
                "field": "bigram",
                "prefix_length": 1
              }
            ],
            "highlight": {
              "pre_tag": "",
              "post_tag": ""
            }
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'an Elasticsearch query', '*indexed_documents*,*news_items*'
end
