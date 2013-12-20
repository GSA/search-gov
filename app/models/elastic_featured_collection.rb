class ElasticFeaturedCollection
  extend Indexable
  ES_SYNONYMS = ["visa, visas"]

  self.settings = {
      index: {
          analysis: {
              filter: {
                  es_synonym: { type: 'synonym', synonyms: ES_SYNONYMS },
                  en_stop_filter: { type: "stop", stopwords: ["_english_"] },
                  en_stem_filter: { type: "stemmer", name: "minimal_english" },
                  es_stop_filter: { type: "stop", stopwords: ["_spanish_"] },
                  es_stem_filter: { type: "stemmer", name: "light_spanish" }
              },
              analyzer: {
                  en_analyzer: {
                      type: "custom",
                      tokenizer: "standard",
                      filter: %w(standard asciifolding lowercase en_stop_filter en_stem_filter) },
                  es_analyzer: {
                      type: "custom",
                      tokenizer: "standard",
                      filter: %w(standard asciifolding lowercase es_synonym es_stop_filter es_stem_filter) },
                  case_insensitive_keyword_analyzer: {
                      tokenizer: 'keyword',
                      filter: %w(standard asciifolding lowercase) } } } }
  }.freeze

  self.mappings = {
      index_type => {
          dynamic: false,
          _analyzer: { path: "language" },
          properties: {
              language: { type: "string", index: :not_analyzed },
              affiliate_id: { type: 'integer' },
              status: { type: 'string', index: :not_analyzed },
              publish_start_on: { type: 'date', format: 'YYYY-MM-dd' },
              publish_end_on: { type: 'date', format: 'YYYY-MM-dd', null_value: '9999-12-31' },
              title: { type: 'string', term_vector: 'with_positions_offsets' },
              link_titles: { type: 'string', term_vector: 'with_positions_offsets' },
              keyword_values: { type: 'string', analyzer: 'case_insensitive_keyword_analyzer' },
              id: { type: 'integer', index: :not_analyzed, include_in_all: false } } }
  }.freeze

end