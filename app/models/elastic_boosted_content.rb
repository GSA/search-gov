class ElasticBoostedContent
  extend Indexable

  self.settings = ElasticSettings::COMMON

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
              description: { type: 'string', term_vector: 'with_positions_offsets' },
              keyword_values: { type: 'string', analyzer: 'case_insensitive_keyword_analyzer' },
              id: { type: 'integer', index: :not_analyzed, include_in_all: false } } }
  }.freeze

end